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
                    VStack(alignment: .leading, spacing: 10) {
                        Text(cloudMagnet.fileName)
                            .font(.callout)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(4)

                        HStack {
                            Text(cloudMagnet.status.capitalizingFirstLetter())
                            Spacer()
                            DebridLabelView(debridSource: debridSource, cloudLinks: cloudMagnet.links)
                        }
                        .font(.caption)
                    }
                }
                .disabledAppearance(navModel.currentChoiceSheet != nil, dimmedOpacity: 0.7, animation: .easeOut(duration: 0.2))
                .tint(.primary)
                .tag(cloudMagnet)
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
}
