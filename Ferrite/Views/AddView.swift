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
    @State private var multiEntryText: String = ""
    @State private var pendingTorrentUrls: [URL] = []
    @State private var showFileImporter = false
    @State private var showTransferBrowser = false
    @State private var transferHandle: DebridTransferHandle?
    @State private var transferTitle: String = ""
    @State private var isProcessing = false
    @State private var processingProgress: String = ""

    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private var selectedDebrid: DebridSource? {
        debridManager.enabledDebrids.first { $0.id == selectedDebridId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.medium) {
                    // Provider Section
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        Text("Provider")
                            .font(DesignTokens.Typography.headline)
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                        
                        if debridManager.enabledDebrids.isEmpty {
                            Text("No debrid providers are enabled.")
                                .foregroundColor(.secondary)
                                .padding(DesignTokens.Spacing.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium)
                                .padding(.horizontal, DesignTokens.Spacing.medium)
                        } else {
                            VStack(spacing: DesignTokens.Spacing.small) {
                                Picker("Service", selection: $selectedDebridId) {
                                    ForEach(debridManager.enabledDebrids, id: \.id) { debrid in
                                        Text(debrid.id).tag(debrid.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(DesignTokens.Spacing.small)

                                if let selectedDebrid {
                                    HStack(spacing: 12) {
                                        capabilityLabel("Web", supported: selectedDebrid.supportsWebLinks)
                                        capabilityLabel("Magnet", supported: selectedDebrid.supportsMagnetUnrestrict)
                                        capabilityLabel("Torrent", supported: selectedDebrid.supportsTorrentUpload)
                                    }
                                    .padding(.horizontal, DesignTokens.Spacing.small)
                                    .padding(.bottom, DesignTokens.Spacing.small)
                                }
                            }
                            .liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium)
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                        }
                    }

                    // Multi-entry input Section
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        Text("Web Links or Magnets")
                            .font(DesignTokens.Typography.headline)
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                        
                        VStack(spacing: DesignTokens.Spacing.small) {
                            Text("Enter one web link or magnet per line")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, DesignTokens.Spacing.small)
                                .padding(.top, DesignTokens.Spacing.small)
                            
                            TextEditor(text: $multiEntryText)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.body)
                                .frame(minHeight: 120)
                                .padding(DesignTokens.Spacing.small)
                                .background(Color.secondary.opacity(0.05))
                                .cornerRadius(DesignTokens.CornerRadius.small)
                                .padding(.horizontal, DesignTokens.Spacing.small)
                                .accessibilityLabel("Links or magnets to process")

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task {
                                    await processMultiEntries()
                                }
                            } label: {
                                HStack {
                                    if isProcessing {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(isProcessing ? "Processing..." : "Process Entries")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(DesignTokens.Spacing.small)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(DesignTokens.CornerRadius.medium)
                            .padding(.horizontal, DesignTokens.Spacing.small)
                            .padding(.bottom, DesignTokens.Spacing.small)
                            .disabled(multiEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                            .accessibilityHint(isProcessing ? "Wait for current processing to finish" : (multiEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Enter web links or magnets first" : ""))
                        }
                        .liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium)
                        .padding(.horizontal, DesignTokens.Spacing.medium)
                    }

                    // Torrent File Section
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        Text("Torrent Files")
                            .font(DesignTokens.Typography.headline)
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                        
                        VStack(spacing: DesignTokens.Spacing.small) {
                            if pendingTorrentUrls.isEmpty {
                                Text("No torrent files selected")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(DesignTokens.Spacing.medium)
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(pendingTorrentUrls.enumerated()), id: \.offset) { index, url in
                                        HStack {
                                            Image(systemName: "doc.fill")
                                                .foregroundColor(.accentColor)
                                            Text(url.lastPathComponent)
                                                .font(.caption)
                                                .lineLimit(1)
                                            Spacer()
                                            Button {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                                pendingTorrentUrls.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                            .accessibilityLabel("Remove torrent")
                                            .accessibilityHint("Removes \(url.lastPathComponent) from the upload list")
                                        }
                                        .padding(.horizontal, DesignTokens.Spacing.small)
                                    }
                                }
                                .padding(.vertical, DesignTokens.Spacing.small)
                            }

                            Button {
                                showFileImporter.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "folder")
                                    Text("Choose Torrent Files")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(DesignTokens.Spacing.small)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(DesignTokens.CornerRadius.medium)
                            .padding(.horizontal, DesignTokens.Spacing.small)
                            .disabled(!(selectedDebrid?.supportsTorrentUpload ?? false))

                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task {
                                    await processTorrentUploads()
                                }
                            } label: {
                                HStack {
                                    if isProcessing {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(isProcessing ? "Uploading..." : "Upload Torrents")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(DesignTokens.Spacing.small)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(DesignTokens.CornerRadius.medium)
                            .padding(.horizontal, DesignTokens.Spacing.small)
                            .padding(.bottom, DesignTokens.Spacing.small)
                            .disabled(!(selectedDebrid?.supportsTorrentUpload ?? false) || pendingTorrentUrls.isEmpty || isProcessing)
                            .accessibilityHint(isProcessing ? "Wait for current processing to finish" : (pendingTorrentUrls.isEmpty ? "Select torrent files first" : ""))
                        }
                        .liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium)
                        .padding(.horizontal, DesignTokens.Spacing.medium)
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.medium)
            }
            .navigationTitle("Download")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [
                    UTType(filenameExtension: "torrent") ?? .data
                ],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case let .success(urls):
                    pendingTorrentUrls.append(contentsOf: urls)
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
            .overlay {
                if isProcessing && !processingProgress.isEmpty {
                    VStack {
                        Text(processingProgress)
                            .font(.caption)
                            .padding(DesignTokens.Spacing.medium)
                            .liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 100)
                }
            }
            .onAppear {
                if selectedDebridId.isEmpty {
                    selectedDebridId = debridManager.enabledDebrids.first?.id ?? ""
                }

                // Auto-process pending items from deep link (sequential to avoid conflicts)
                Task {
                    // Process torrents first if present
                    if let pendingUrls = navModel.pendingTorrentUrls, !pendingUrls.isEmpty {
                        pendingTorrentUrls = pendingUrls
                        navModel.pendingTorrentUrls = nil
                        await processTorrentUploads()
                    }
                    
                    // Then process magnet if present
                    if let magnetLink = navModel.pendingMagnetLink {
                        multiEntryText = magnetLink
                        navModel.pendingMagnetLink = nil
                        await processMultiEntries()
                    }
                }
            }
            .onChange(of: selectedDebridId) { newValue in
                if let match = debridManager.enabledDebrids.first(where: { $0.id == newValue }) {
                    debridManager.selectedDebridSource = match
                }
            }
            .onChange(of: navModel.pendingTorrentUrls) { newValue in
                guard !isProcessing else { return }
                if let newValue, !newValue.isEmpty {
                    pendingTorrentUrls.append(contentsOf: newValue)
                    navModel.pendingTorrentUrls = nil
                    Task {
                        await processTorrentUploads()
                    }
                }
            }
            .onChange(of: navModel.pendingMagnetLink) { newValue in
                guard !isProcessing else { return }
                if let newValue {
                    multiEntryText = newValue
                    navModel.pendingMagnetLink = nil
                    Task {
                        await processMultiEntries()
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
    
    // MARK: - Multi-entry Processing

    private func processMultiEntries() async {
        guard let selectedDebrid else {
            return
        }
        
        isProcessing = true
        defer { 
            isProcessing = false
            processingProgress = ""
        }
        
        let entries = multiEntryText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var lastHandle: DebridTransferHandle?
        var lastTitle: String?
        var errorCount = 0
        
        for (index, entry) in entries.enumerated() {
            processingProgress = "Processing \(index + 1) of \(entries.count)"
            
            do {
                if isValidMagnet(entry), selectedDebrid.supportsMagnetUnrestrict {
                    let handle = try await selectedDebrid.addMagnetLink(entry)
                    lastHandle = handle
                    lastTitle = extractMagnetName(entry) ?? "Magnet Link"
                    logManager.info("Added magnet link")
                } else if isValidWebLink(entry), selectedDebrid.supportsWebLinks {
                    let handle = try await selectedDebrid.addWebLink(entry)
                    lastHandle = handle
                    lastTitle = entry
                    logManager.info("Added web link")
                } else {
                    errorCount += 1
                    logManager.warn("Skipped invalid entry: \(entry)")
                }
            } catch {
                errorCount += 1
                logManager.error("Failed to process entry: \(error.localizedDescription)")
            }
        }
        
        // Show last transfer browser if any succeeded
        if let lastHandle, let lastTitle {
            transferHandle = lastHandle
            transferTitle = lastTitle
            showTransferBrowser = true
        }
        
        if errorCount > 0 {
            logManager.info("\(entries.count - errorCount) succeeded, \(errorCount) failed")
        } else {
            logManager.info("All \(entries.count) entries processed successfully")
        }
        
        // Clear the text field after processing
        multiEntryText = ""
    }
    
    // MARK: - Torrent Upload Processing

    private func processTorrentUploads() async {
        guard let selectedDebrid else {
            return
        }
        guard selectedDebrid.supportsTorrentUpload else {
            return
        }
        
        isProcessing = true
        defer { 
            isProcessing = false
            processingProgress = ""
        }
        
        var lastHandle: DebridTransferHandle?
        var lastTitle: String?
        var errorCount = 0
        
        for (index, url) in pendingTorrentUrls.enumerated() {
            processingProgress = "Uploading \(index + 1) of \(pendingTorrentUrls.count)"
            
            guard url.pathExtension.lowercased() == "torrent" else {
                errorCount += 1
                logManager.warn("Skipped non-torrent file: \(url.lastPathComponent)")
                continue
            }
            
            do {
                let handle = try await selectedDebrid.uploadTorrentFile(url)
                lastHandle = handle
                lastTitle = url.lastPathComponent
                logManager.info("Uploaded: \(url.lastPathComponent)")
            } catch {
                errorCount += 1
                logManager.error("Upload failed for \(url.lastPathComponent): \(error.localizedDescription)")
            }
        }
        
        // Show last transfer browser if any succeeded
        if let lastHandle, let lastTitle {
            transferHandle = lastHandle
            transferTitle = lastTitle
            showTransferBrowser = true
        }
        
        if errorCount > 0 {
            logManager.info("\(pendingTorrentUrls.count - errorCount) succeeded, \(errorCount) failed")
        } else {
            logManager.info("All \(pendingTorrentUrls.count) torrents uploaded successfully")
        }
        
        // Clear torrent list after processing
        pendingTorrentUrls.removeAll()
    }
    
    // Extract display name from magnet link (from dn parameter if available)
    private func extractMagnetName(_ magnetLink: String) -> String? {
        // Look for dn= parameter (can be prefixed with & or ? or be the first param)
        let patterns = ["&dn=", "?dn="]
        
        for pattern in patterns {
            if let dnRange = magnetLink.range(of: pattern) {
                let afterDn = magnetLink[dnRange.upperBound...]
                let endRange = afterDn.range(of: "&") ?? afterDn.endIndex..<afterDn.endIndex
                let encodedName = String(afterDn[..<endRange.lowerBound])
                
                if let decodedName = encodedName.removingPercentEncoding, !decodedName.isEmpty {
                    return decodedName
                }
            }
        }
        
        return nil
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
