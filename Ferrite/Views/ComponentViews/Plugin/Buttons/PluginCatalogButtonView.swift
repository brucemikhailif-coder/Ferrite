//
//  PluginCatalogButtonView.swift
//  Ferrite
//
//  Created by Brian Dashore on 8/5/22.
//

import SwiftUI

struct PluginCatalogButtonView<PJ: PluginJson>: View {
    @EnvironmentObject var pluginManager: PluginManager

    let availablePlugin: PJ
    let needsUpdate: Bool

    var body: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.medium) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.tiny) {
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.tiny) {
                        Text(availablePlugin.name)
                            .font(DesignTokens.Typography.headline)

                        Text("v\(availablePlugin.version)")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    Group {
                        Text("by \(availablePlugin.author ?? "No author")")
                            .font(DesignTokens.Typography.caption)

                        Text(availablePlugin.listName.map { "from \($0)" } ?? "an unknown list")
                            .font(DesignTokens.Typography.caption)
                    }
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }

                let tags = availablePlugin.getTags()
                if !tags.isEmpty {
                    PluginTagsView(tags: tags)
                }
            }

            Spacer(minLength: DesignTokens.Spacing.medium)

            Button(needsUpdate ? "Update" : "Install") {
                Task {
                    if let availableSource = availablePlugin as? SourceJson {
                        await pluginManager.installSource(sourceJson: availableSource, doUpsert: needsUpdate)
                    } else if let availableAction = availablePlugin as? ActionJson {
                        await pluginManager.installAction(actionJson: availableAction, doUpsert: needsUpdate)
                    } else {
                        return
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .font(.caption.weight(.semibold))
        }
        .buttonStyle(.borderless)
        .padding(.vertical, DesignTokens.Spacing.small)
        .frame(minHeight: DesignTokens.Interactive.minTapTarget, alignment: .leading)
    }
}
