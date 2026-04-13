//
//  SourceListView.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/24/22.
//
import SwiftUI

struct PluginAggregateView<P: Plugin, PJ: PluginJson>: View {
    @EnvironmentObject var pluginManager: PluginManager
    @EnvironmentObject var navModel: NavigationViewModel

    let backgroundContext = PersistenceController.shared.backgroundContext

    @FetchRequest(
        entity: PluginList.entity(),
        sortDescriptors: []
    ) var pluginLists: FetchedResults<PluginList>

    var installedPlugins: FetchedResults<P>

    @AppStorage("Behavior.AutocorrectSearch") var autocorrectSearch = true

    @Binding var searchText: String

    @State private var isEditingSearch = false
    @State private var isSearching = false

    @State private var sourcePredicate: NSPredicate?

    @State private var showPluginOptions = false
    @State private var selectedPlugin: P?

    var body: some View {
        List {
            let filteredUpdatedPlugins = pluginManager.fetchUpdatedPlugins(
                forType: PJ.self,
                installedPlugins: installedPlugins,
                searchText: searchText
            )
            if !filteredUpdatedPlugins.isEmpty {
                Section {
                    ForEach(filteredUpdatedPlugins, id: \.self) { (updatedPlugin: PJ) in
                        PluginCatalogButtonView(availablePlugin: updatedPlugin, needsUpdate: true)
                    }
                } header: {
                    SectionHeaderView(title: "Updates", subtitle: "Installed plugins with newer versions available")
                }
            }

            if !installedPlugins.isEmpty {
                Section {
                    ForEach(installedPlugins, id: \.self) { installedPlugin in
                        InstalledPluginButtonView(
                            installedPlugin: installedPlugin,
                            showPluginOptions: $showPluginOptions,
                            selectedPlugin: $selectedPlugin
                        )
                    }
                } header: {
                    SectionHeaderView(title: "Installed", subtitle: "Enabled plugins available on this device")
                }
            }

            let filteredAvailablePlugins = pluginManager.fetchFilteredPlugins(
                forType: PJ.self,
                installedPlugins: installedPlugins,
                searchText: searchText
            )
            if !filteredAvailablePlugins.isEmpty {
                Section {
                    ForEach(filteredAvailablePlugins, id: \.self) { availablePlugin in
                        PluginCatalogButtonView(availablePlugin: availablePlugin, needsUpdate: false)
                    }
                } header: {
                    SectionHeaderView(title: "Catalog", subtitle: "Available plugins from your configured lists")
                }
            }
        }
        .listStyle(.insetGrouped)
        .onAppear {
            fetchPredicate()
        }
        .onChange(of: searchText) { _ in
            fetchPredicate()
        }
        // Alternatively, place the sheet in the parent view
        .refreshable {
            await pluginManager.fetchPluginsFromUrl()
        }
        .sheet(isPresented: $showPluginOptions) {
            PluginInfoView(selectedPlugin: $selectedPlugin)
        }
    }

    func fetchPredicate() {
        installedPlugins.nsPredicate = searchText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", searchText)
    }
}
