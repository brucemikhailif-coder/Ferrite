//
//  CloudMagnetView.swift
//  Ferrite
//
//  Created by Brian Dashore on 6/6/24.
//

import SwiftUI

struct CloudMagnetView: View {
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var debridManager: DebridManager

    @Store var debridSource: DebridSource

    @Binding var searchText: String
    @State private var showTransferBrowser = false
    @State private var transferHandle: DebridTransferHandle?
    @State private var transferTitle: String = ""

    var body: some View {
        DisclosureGroup("Magnets") {
            ForEach(debridSource.cloudMagnets.filter {
                searchText.isEmpty ? true : $0.fileName.lowercased().contains(searchText.lowercased())
            }, id: \.self) { cloudMagnet in
                Button {
                    if debridSource.cachedStatus.contains(cloudMagnet.status), !cloudMagnet.links.isEmpty {
                        navModel.resultFromCloud = true
                        navModel.selectedTitle = cloudMagnet.fileName
                        navModel.selectedMagnet = nil
                        transferHandle = DebridTransferHandle(id: cloudMagnet.id, kind: .torrent)
                        transferTitle = cloudMagnet.fileName
                        showTransferBrowser = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(statusColor(cloudMagnet.status))
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(cloudMagnet.fileName)
                                .font(.callout)
                                .lineLimit(2)

                            HStack(spacing: 8) {
                                Text(cloudMagnet.status.capitalizingFirstLetter())
                                Text("\(cloudMagnet.links.count) files")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }

                        Spacer()

                        DebridLabelView(debridSource: debridSource, cloudLinks: cloudMagnet.links)
                    }
                    .padding(10)
                    .liquidGlass(cornerRadius: 14)
                }
                .disabledAppearance(navModel.currentChoiceSheet != nil, dimmedOpacity: 0.7, animation: .easeOut(duration: 0.2))
                .tint(.primary)
                .tag(cloudMagnet)
                .listRowBackground(Color.clear)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = cloudMagnet.hash
                    } label: {
                        Text("Copy hash")
                        Image(systemName: "doc.on.doc.fill")
                    }

                    Button(role: .destructive) {
                        Task {
                            await debridManager.deleteUserMagnet(cloudMagnet)
                        }
                    } label: {
                        Text("Delete magnet")
                        Image(systemName: "trash.fill")
                    }
                }
            }
            .onDelete { offsets in
                for index in offsets {
                    if let cloudMagnet = debridSource.cloudMagnets[safe: index] {
                        Task {
                            await debridManager.deleteUserMagnet(cloudMagnet)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showTransferBrowser) {
            if let transferHandle {
                DebridTransferBrowserView(
                    debridSource: debridSource,
                    handle: transferHandle,
                    title: transferTitle,
                    resultFromCloud: true
                )
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        if debridSource.cachedStatus.contains(status) {
            return .green
        }

        if status.lowercased().contains("error") {
            return .red
        }

        return .orange
    }
}
