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
    @State private var showDeleteConfirm: Bool = false
    @State private var pendingDeleteMagnet: DebridCloudMagnet?

    private var filteredMagnets: [DebridCloudMagnet] {
        debridSource.cloudMagnets.filter {
            searchText.isEmpty ? true : $0.fileName.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        Section {
            ForEach(filteredMagnets, id: \.self) { cloudMagnet in
                Button {
                    openTransferBrowser(for: cloudMagnet)
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

                            if let progress = debridManager.transferProgress?[cloudMagnet.id] {
                                ProgressView(value: progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                                    .frame(height: DesignTokens.Sizes.progressHeight)
                                    .clipShape(Capsule())
                                    .padding(.top, DesignTokens.Spacing.small)
                            }
                        }

                        Spacer()

                        DebridLabelView(debridSource: debridSource, cloudLinks: cloudMagnet.links)
                    }
                    .padding(DesignTokens.Spacing.small)
                    .liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium)
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

                    Button {
                        openTransferBrowser(for: cloudMagnet)
                    } label: {
                        Text("Open files")
                        Image(systemName: "play.rectangle")
                    }

                    Button {
                        openMagnetActions(for: cloudMagnet)
                    } label: {
                        Text("Magnet actions")
                        Image(systemName: "bolt.horizontal.circle")
                    }

                    Button {
                        pendingDeleteMagnet = cloudMagnet
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete magnet")
                        Image(systemName: "trash.fill")
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        UIPasteboard.general.string = cloudMagnet.hash
                    } label: {
                        Label("Copy hash", systemImage: "doc.on.doc.fill")
                    }
                    .tint(.blue)

                    Button {
                        openTransferBrowser(for: cloudMagnet)
                    } label: {
                        Label("Open files", systemImage: "play.rectangle")
                    }
                    .tint(.purple)

                    Button {
                        openMagnetActions(for: cloudMagnet)
                    } label: {
                        Label("Magnet actions", systemImage: "bolt.horizontal.circle")
                    }
                    .tint(.orange)

                    Button(role: .destructive) {
                        pendingDeleteMagnet = cloudMagnet
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(cloudMagnet.fileName), \(cloudMagnet.links.count) files, status \(cloudMagnet.status)")
                .accessibilityHint("Double tap to open the magnet details")
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
        .confirmationDialog("Delete magnet?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let magnet = pendingDeleteMagnet {
                    Task {
                        await debridManager.deleteUserMagnet(magnet)
                        pendingDeleteMagnet = nil
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteMagnet = nil
            }
        } message: {
            if let magnet = pendingDeleteMagnet {
                Text("Are you sure you want to delete \"\(magnet.fileName)\"?")
            } else {
                Text("Are you sure you want to delete this magnet?")
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

    private func openTransferBrowser(for cloudMagnet: DebridCloudMagnet) {
        guard debridSource.cachedStatus.contains(cloudMagnet.status), !cloudMagnet.links.isEmpty else {
            return
        }

        navModel.resultFromCloud = true
        navModel.selectedTitle = cloudMagnet.fileName
        navModel.selectedMagnet = Magnet(hash: cloudMagnet.hash, link: nil, title: cloudMagnet.fileName)
        transferHandle = DebridTransferHandle(id: cloudMagnet.id, kind: .torrent)
        transferTitle = cloudMagnet.fileName
        showTransferBrowser = true
    }

    private func openMagnetActions(for cloudMagnet: DebridCloudMagnet) {
        navModel.resultFromCloud = true
        navModel.selectedTitle = cloudMagnet.fileName
        navModel.selectedBatchTitle = ""
        navModel.selectedMagnet = Magnet(hash: cloudMagnet.hash, link: nil, title: cloudMagnet.fileName)

        // TorBox stores file IDs ("0", "1", ...) in cloudMagnet.links. They are
        // not playable URLs. Keep magnet plugins on the magnet path and leave
        // playback to DebridTransferBrowserView -> requestdl.
        debridManager.downloadUrl = ""
        navModel.currentChoiceSheet = .action
    }
}

//
// Previews: Dynamic Type variants for CloudMagnetView
//
struct CloudMagnetView_Previews: PreviewProvider {
    static var sampleMagnet = DebridCloudMagnet(
        id: "m1",
        fileName: "Sample Series - Episode 1 — A very long title intended to exercise wrapping and accessibility dynamic type scaling",
        status: "downloaded",
        hash: "abc123",
        links: ["0"]
    )

    static var debridManager = DebridManager()
    static var navModel = NavigationViewModel()
    static var logManager = LoggingManager()

    static var previews: some View {
        Group {
            CloudMagnetView(debridSource: RealDebrid(), searchText: .constant(""))
                .environmentObject(navModel)
                .environmentObject(debridManager)
                .environmentObject(logManager)
                .previewDisplayName("Magnets — Default")

            CloudMagnetView(debridSource: RealDebrid(), searchText: .constant(""))
                .environmentObject(navModel)
                .environmentObject(debridManager)
                .environmentObject(logManager)
                .environment(\.sizeCategory, .accessibilityExtraLarge)
                .previewDisplayName("Magnets — Large Dynamic Type")

            CloudMagnetView(debridSource: RealDebrid(), searchText: .constant(""))
                .environmentObject(navModel)
                .environmentObject(debridManager)
                .environmentObject(logManager)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("Magnets — Accessibility XXL")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
