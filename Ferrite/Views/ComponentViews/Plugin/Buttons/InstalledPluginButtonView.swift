//
//  InstalledPluginButtonView.swift
//  Ferrite
//
//  Created by Brian Dashore on 8/5/22.
//

import SwiftUI

struct InstalledPluginButtonView<P: Plugin>: View {
    let backgroundContext = PersistenceController.shared.backgroundContext

    @ObservedObject var installedPlugin: P

    @Binding var showPluginOptions: Bool
    @Binding var selectedPlugin: P?

    var body: some View {
        Toggle(isOn: Binding<Bool>(
            get: { installedPlugin.enabled },
            set: {
                installedPlugin.enabled = $0
                PersistenceController.shared.save()
            }
        )) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.tiny) {
                    HStack(spacing: DesignTokens.Spacing.tiny) {
                        Text(installedPlugin.name)
                            .font(.headline)

                        Text("v\(installedPlugin.version)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text("by \(installedPlugin.author)")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                let tags = installedPlugin.getTags()
                if !tags.isEmpty {
                    PluginTagsView(tags: tags)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.tiny)
        }
        .contextMenu {
            Button {
                selectedPlugin = installedPlugin
                showPluginOptions.toggle()
            } label: {
                Text("Options")
                Image(systemName: "gear")
            }

            Button(role: .destructive) {
                PersistenceController.shared.delete(installedPlugin, context: backgroundContext)
            } label: {
                Text("Remove")
                Image(systemName: "trash")
            }
        }
    }
}
