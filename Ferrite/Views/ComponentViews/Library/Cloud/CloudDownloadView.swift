//
//  CloudDownloadView.swift
//  Ferrite
//
//  Created by Brian Dashore on 6/6/24.
//

import SwiftUI

struct CloudDownloadView: View {
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var debridManager: DebridManager

    @Store var debridSource: DebridSource

    @Binding var searchText: String
    @State private var showTransferBrowser = false
    @State private var transferHandle: DebridTransferHandle?
    @State private var transferFiles: [DebridTransferFile] = []
    @State private var transferTitle: String = ""

    var body: some View {
        DisclosureGroup("Downloads") {
            ForEach(filteredDownloads, id: \.self) { cloudDownload in
                CloudDownloadRow(cloudDownload: cloudDownload) {
                    handleDownloadSelection(cloudDownload)
                }
                .disabledAppearance(navModel.currentChoiceSheet != nil,
                                    dimmedOpacity: 0.7,
                                    animation: .easeOut(duration: 0.2))
                .tag(cloudDownload)
                .listRowBackground(Color.clear)
                .contextMenu {
                    contextMenuContent(for: cloudDownload)
                }
            }
            .onDelete(perform: deleteDownloads)
        }
        .sheet(isPresented: $showTransferBrowser) {
            transferBrowserView
        }
    }

    private var filteredDownloads: [DebridCloudDownload] {
        debridSource.cloudDownloads.filter {
            searchText.isEmpty ? true : $0.fileName.lowercased().contains(searchText.lowercased())
        }
    }

    @ViewBuilder
    private var transferBrowserView: some View {
        if let transferHandle {
            DebridTransferBrowserView(
                debridSource: debridSource,
                handle: transferHandle,
                initialFiles: transferFiles,
                title: transferTitle,
                resultFromCloud: true
            )
        }
    }

    private func handleDownloadSelection(_ cloudDownload: DebridCloudDownload) {
        navModel.resultFromCloud = true
        navModel.selectedTitle = cloudDownload.fileName
        navModel.selectedMagnet = nil

        let fileLink = cloudDownload.link.isEmpty ? nil : cloudDownload.link
        transferFiles = [
            DebridTransferFile(
                id: cloudDownload.id,
                name: cloudDownload.fileName,
                link: fileLink
            )
        ]
        transferHandle = DebridTransferHandle(id: cloudDownload.id, kind: .webDownload)
        transferTitle = cloudDownload.fileName
        showTransferBrowser = true
    }

    @ViewBuilder
    private func contextMenuContent(for cloudDownload: DebridCloudDownload) -> some View {
        Button {
            UIPasteboard.general.string = cloudDownload.link
        } label: {
            Text("Copy download URL")
            Image(systemName: "doc.on.doc.fill")
        }

        Button {
            if let url = URL(string: cloudDownload.link) {
                navModel.activityItems = [url]
                navModel.currentChoiceSheet = .activity
            }
        } label: {
            Text("Share download URL")
            Image(systemName: "square.and.arrow.up.fill")
        }

        Button {
            if let url = URL(string: cloudDownload.link) {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("Open in Safari")
            Image(systemName: "safari.fill")
        }

        Button(role: .destructive) {
            Task {
                await debridManager.deleteCloudDownload(cloudDownload)
            }
        } label: {
            Text("Delete download")
            Image(systemName: "trash.fill")
        }
    }

    private func deleteDownloads(at offsets: IndexSet) {
        for index in offsets {
            if let cloudDownload = debridSource.cloudDownloads[safe: index] {
                Task {
                    await debridManager.deleteCloudDownload(cloudDownload)
                }
            }
        }
    }
}

private struct CloudDownloadRow: View {
    let cloudDownload: DebridCloudDownload
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.accent)

                VStack(alignment: .leading, spacing: 6) {
                    Text(cloudDownload.fileName)
                        .font(.callout)
                        .lineLimit(2)

                    Text("Web download")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(10)
            .liquidGlass(cornerRadius: 14)
        }
        .tint(.primary)
    }
}
