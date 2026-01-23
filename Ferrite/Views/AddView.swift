//
//  AddView.swift
//  Ferrite
//
//  Created by Brian Dashore on 1/24/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddView: View {
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var debridManager: DebridManager
    @EnvironmentObject var logManager: LoggingManager

    @State private var selectedDebridId: String = ""
    @State private var webLinkText: String = ""
    @State private var magnetText: String = ""
    @State private var pendingTorrentUrl: URL?
    @State private var showFileImporter = false
    @State private var showTransferBrowser = false
    @State private var transferHandle: DebridTransferHandle?
    @State private var transferTitle: String = ""

    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private var selectedDebrid: DebridSource? {
        debridManager.enabledDebrids.first { $0.id == selectedDebridId }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Provider") {
                    if debridManager.enabledDebrids.isEmpty {
                        Text("No debrid providers are enabled.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Service", selection: $selectedDebridId) {
                            ForEach(debridManager.enabledDebrids, id: \.id) { debrid in
                                Text(debrid.id).tag(debrid.id)
                            }
                        }

                        if let selectedDebrid {
                            HStack(spacing: 12) {
                                capabilityLabel("Web", supported: selectedDebrid.supportsWebLinks)
                                capabilityLabel("Magnet", supported: selectedDebrid.supportsMagnetUnrestrict)
                                capabilityLabel("Torrent", supported: selectedDebrid.supportsTorrentUpload)
                            }
                        }
                    }
                }

                Section("Web link") {
                    TextField("https://", text: $webLinkText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)

                    Button("Process web link") {
                        Task {
                            await startWebLink()
                        }
                    }
                    .disabled(!(selectedDebrid?.supportsWebLinks ?? false) || webLinkText.isEmpty)
                }

                Section("Magnet") {
                    TextField("magnet:?xt=urn:btih:...", text: $magnetText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Unrestrict magnet") {
                        Task {
                            await startMagnet()
                        }
                    }
                    .disabled(!(selectedDebrid?.supportsMagnetUnrestrict ?? false) || magnetText.isEmpty)
                }

                Section("Torrent") {
                    if let pendingTorrentUrl {
                        Text(pendingTorrentUrl.lastPathComponent)
                            .font(.subheadline)
                    } else {
                        Text("No torrent selected")
                            .foregroundColor(.secondary)
                    }

                    Button("Choose torrent file") {
                        showFileImporter.toggle()
                    }
                    .disabled(!(selectedDebrid?.supportsTorrentUpload ?? false))

                    Button("Upload torrent") {
                        Task {
                            await startTorrentUpload()
                        }
                    }
                    .disabled(!(selectedDebrid?.supportsTorrentUpload ?? false) || pendingTorrentUrl == nil)
                }
            }
            .navigationTitle("Add")
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [
                    UTType(filenameExtension: "torrent") ?? .data
                ],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case let .success(urls):
                    pendingTorrentUrl = urls.first
                case let .failure(error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
            .sheet(isPresented: $showTransferBrowser) {
                if let selectedDebrid, let transferHandle {
                    DebridTransferBrowserView(
                        debridSource: selectedDebrid,
                        handle: transferHandle,
                        title: transferTitle,
                        resultFromCloud: true
                    )
                }
            }
            .alert("Transfer error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if selectedDebridId.isEmpty {
                    selectedDebridId = debridManager.enabledDebrids.first?.id ?? ""
                }

                if let pendingTorrentUrl = navModel.pendingTorrentUrl {
                    self.pendingTorrentUrl = pendingTorrentUrl
                    navModel.pendingTorrentUrl = nil
                }
            }
            .onChange(of: selectedDebridId) { newValue in
                if let match = debridManager.enabledDebrids.first(where: { $0.id == newValue }) {
                    debridManager.selectedDebridSource = match
                }
            }
            .onChange(of: navModel.pendingTorrentUrl) { newValue in
                if let newValue {
                    pendingTorrentUrl = newValue
                    navModel.pendingTorrentUrl = nil
                    Task {
                        await startTorrentUpload()
                    }
                }
            }
        }
    }

    private func capabilityLabel(_ title: String, supported: Bool) -> some View {
        Label(
            title,
            systemImage: supported ? "checkmark.circle.fill" : "xmark.circle.fill"
        )
        .font(.caption)
        .foregroundColor(supported ? .green : .secondary)
    }

    private func startWebLink() async {
        guard let selectedDebrid else {
            return
        }
        guard selectedDebrid.supportsWebLinks else {
            return
        }
        guard isValidWebLink(webLinkText) else {
            errorMessage = "Please enter a valid web link."
            showErrorAlert = true
            return
        }

        do {
            transferHandle = try await selectedDebrid.addWebLink(webLinkText)
            transferTitle = webLinkText
            showTransferBrowser = true
        } catch {
            logManager.error("Add web link error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func startMagnet() async {
        guard let selectedDebrid else {
            return
        }
        guard selectedDebrid.supportsMagnetUnrestrict else {
            return
        }
        guard isValidMagnet(magnetText) else {
            errorMessage = "Please enter a valid magnet link."
            showErrorAlert = true
            return
        }

        do {
            transferHandle = try await selectedDebrid.addMagnetLink(magnetText)
            transferTitle = "Magnet"
            showTransferBrowser = true
        } catch {
            logManager.error("Add magnet error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func startTorrentUpload() async {
        guard let selectedDebrid, let pendingTorrentUrl else {
            return
        }
        guard selectedDebrid.supportsTorrentUpload else {
            return
        }
        guard pendingTorrentUrl.pathExtension.lowercased() == "torrent" else {
            errorMessage = "Please select a .torrent file."
            showErrorAlert = true
            return
        }

        do {
            transferHandle = try await selectedDebrid.uploadTorrentFile(pendingTorrentUrl)
            transferTitle = pendingTorrentUrl.lastPathComponent
            showTransferBrowser = true
        } catch {
            logManager.error("Torrent upload error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func isValidWebLink(_ link: String) -> Bool {
        guard let url = URL(string: link) else {
            return false
        }
        return ["http", "https"].contains(url.scheme?.lowercased() ?? "")
    }

    private func isValidMagnet(_ link: String) -> Bool {
        link.lowercased().starts(with: "magnet:?xt=urn:btih:")
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
