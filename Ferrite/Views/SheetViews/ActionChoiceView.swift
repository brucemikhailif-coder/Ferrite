//
//  ActionChoiceView.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/20/22.
//

import SwiftUI

struct ActionChoiceView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var scrapingModel: ScrapingViewModel
    @EnvironmentObject var debridManager: DebridManager
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var pluginManager: PluginManager

    @FetchRequest(
        entity: Action.entity(),
        sortDescriptors: []
    ) var actions: FetchedResults<Action>

    @FetchRequest(
        entity: KodiServer.entity(),
        sortDescriptors: []
    ) var kodiServers: FetchedResults<KodiServer>

    @State private var showLinkCopyAlert = false
    @State private var showMagnetCopyAlert = false
    @State private var showLocalActivitySheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.tiny) {
                        Text(navModel.selectedTitle)
                            .font(.headline)
                            .lineLimit(navModel.selectedBatchTitle.isEmpty ? .max : 1)

                        if !navModel.selectedBatchTitle.isEmpty {
                            Text(navModel.selectedBatchTitle)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }
                } header: {
                    SectionHeaderView(title: "Now Playing", subtitle: "Current item and selected file context")
                }

                if !debridManager.downloadUrl.isEmpty {
                    Section {
                        if let defaultDebridAction, defaultDebridAction != .none {
                            ListRowButtonView("Default action", systemImage: "sparkles") {
                                performDefaultAction(defaultDebridAction, urlString: debridManager.downloadUrl)
                            }
                        }

                        ForEach(actions, id: \.id) { action in
                            if action.requires.contains(ActionRequirement.debrid.rawValue) {
                                ListRowButtonView(action.name, systemImage: "arrow.up.forward.app.fill") {
                                    pluginManager.runDeeplinkAction(action, urlString: debridManager.downloadUrl)
                                }
                            }
                        }

                        ListRowButtonView("Open in Safari", systemImage: "safari.fill") {
                            if let url = URL(string: debridManager.downloadUrl),
                               ["http", "https"].contains(url.scheme?.lowercased() ?? "")
                            {
                                UIApplication.shared.open(url)
                            }
                        }

                        if !kodiServers.isEmpty {
                            DisclosureGroup("Open in Kodi", isExpanded: $navModel.kodiExpanded) {
                                ForEach(kodiServers, id: \.self) { server in
                                    Button {
                                        Task {
                                            await pluginManager.sendToKodi(urlString: debridManager.downloadUrl, server: server)
                                        }
                                    } label: {
                                        KodiServerView(server: server)
                                    }
                                    .tint(.primary)
                                }
                            }
                            .tint(.secondary)
                        }

                        ListRowButtonView("Copy download URL", systemImage: "doc.on.doc.fill") {
                            UIPasteboard.general.string = debridManager.downloadUrl
                            showLinkCopyAlert.toggle()
                        }
                        .alert("Copied", isPresented: $showLinkCopyAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Download link copied successfully")
                        }

                        ListRowButtonView("Share download URL", systemImage: "square.and.arrow.up.fill") {
                            presentActivityItems(for: debridManager.downloadUrl)
                        }
                    } header: {
                        SectionHeaderView(title: "Debrid Options", subtitle: "Actions available for the generated download link")
                    }
                }

                if !navModel.resultFromCloud {
                    Section {
                        if let defaultMagnetAction, defaultMagnetAction != .none {
                            ListRowButtonView("Default action", systemImage: "sparkles") {
                                performDefaultAction(defaultMagnetAction, urlString: navModel.selectedMagnet?.link)
                            }
                        }

                        ForEach(actions, id: \.id) { action in
                            if action.requires.contains(ActionRequirement.magnet.rawValue) {
                                ListRowButtonView(action.name, systemImage: "arrow.up.forward.app.fill") {
                                    pluginManager.runDeeplinkAction(action, urlString: navModel.selectedMagnet?.link)
                                }
                            }
                        }

                        ListRowButtonView("Copy magnet", systemImage: "doc.on.doc.fill") {
                            UIPasteboard.general.string = navModel.selectedMagnet?.link
                            showMagnetCopyAlert.toggle()
                        }
                        .alert("Copied", isPresented: $showMagnetCopyAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Magnet link copied successfully")
                        }

                        ListRowButtonView("Share magnet", systemImage: "square.and.arrow.up.fill") {
                            presentActivityItems(for: navModel.selectedMagnet?.link)
                        }
                    } header: {
                        SectionHeaderView(title: "Magnet Options", subtitle: "Actions available for the original magnet link")
                    }
                }
            }
            .tint(.primary)
            .sheet(isPresented: $showLocalActivitySheet) {
                ShareSheet(activityItems: navModel.activityItems)
                    .presentationDetents([.medium, .large])
            }
            .alert("Action successful", isPresented: $pluginManager.showActionSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(pluginManager.actionSuccessAlertMessage)
            }
            .alert("Action error", isPresented: $pluginManager.showActionErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(pluginManager.actionErrorAlertMessage)
            }
            .onDisappear {
                clearSelectionState()
            }
            .navigationTitle("Link actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        clearSelectionState()
                        dismiss()
                    }
                }
            }
        }
    }

    private var defaultDebridAction: DefaultAction? {
        defaultAction(forKey: "Actions.DefaultDebrid")
    }

    private var defaultMagnetAction: DefaultAction? {
        defaultAction(forKey: "Actions.DefaultMagnet")
    }

    private func defaultAction(forKey key: String) -> DefaultAction? {
        guard
            let rawValue = UserDefaults.standard.string(forKey: key),
            let wrapper = CodableWrapper<DefaultAction>(rawValue: rawValue)
        else {
            return nil
        }

        return wrapper.value
    }

    private func performDefaultAction(_ action: DefaultAction, urlString: String?) {
        switch action {
        case .none:
            break
        case .share:
            presentActivityItems(for: urlString)
        case .kodi:
            navModel.kodiExpanded = true
        case let .custom(name, listId):
            let actionFetchRequest = Action.fetchRequest()
            actionFetchRequest.fetchLimit = 1
            actionFetchRequest.predicate = NSPredicate(format: "name == %@ AND listId == %@", name, listId)

            if let fetchedAction = try? PersistenceController.shared.backgroundContext.fetch(actionFetchRequest).first {
                pluginManager.runDeeplinkAction(fetchedAction, urlString: urlString)
            } else {
                pluginManager.actionErrorAlertMessage =
                    "The default action could not be run. Please check your default actions in Settings."
                pluginManager.showActionErrorAlert.toggle()
            }
        }
    }

    private func presentActivityItems(for urlString: String?) {
        guard let urlString, !urlString.isEmpty else {
            return
        }

        if let url = URL(string: urlString) {
            navModel.activityItems = [url]
        } else {
            navModel.activityItems = [urlString]
        }

        showLocalActivitySheet = true
    }

    private func clearSelectionState() {
        debridManager.downloadUrl = ""
        debridManager.clearSelectedDebridItems()
        debridManager.requiresUnrestrict = false
        navModel.selectedTitle = ""
        navModel.selectedBatchTitle = ""
        navModel.resultFromCloud = false
        navModel.selectedMagnet = nil
        navModel.activityItems = []
    }
}

struct ActionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ActionChoiceView()
    }
}
