//
//  ListRowViews.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/26/22.
//
//  List row button, text, and link boilerplate
//

import SwiftUI

private enum ListRowMetrics {
    static let contentSpacing = DesignTokens.Spacing.medium
    static let minimumTrailingSpacing = DesignTokens.Spacing.medium
    static let verticalPadding = DesignTokens.Spacing.small
    static let accessoryFont = Font.caption.weight(.semibold)
}

struct ListRowLinkView: View {
    let text: String
    let link: String

    private var destinationURL: URL? {
        URL(string: link)
    }

    var body: some View {
        Group {
            if let destinationURL {
                Link(destination: destinationURL) {
                    rowLabel
                }
            } else {
                rowLabel
                    .disabled(true)
            }
        }
        .buttonStyle(.plain)
    }

    private var rowLabel: some View {
        HStack(spacing: ListRowMetrics.contentSpacing) {
            Text(text)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.primary)

            Spacer(minLength: ListRowMetrics.minimumTrailingSpacing)

            Image(systemName: "arrow.up.forward.app")
                .font(ListRowMetrics.accessoryFont)
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.vertical, ListRowMetrics.verticalPadding)
        .frame(maxWidth: .infinity, minHeight: DesignTokens.Interactive.minTapTarget, alignment: .leading)
        .contentShape(Rectangle())
    }
}

struct ListRowButtonView: View {
    let text: String
    let systemImage: String?
    let action: () -> Void

    init(_ text: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.text = text
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: ListRowMetrics.contentSpacing) {
                Text(text)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.primary)

                Spacer(minLength: ListRowMetrics.minimumTrailingSpacing)

                if let imageName = systemImage {
                    Image(systemName: imageName)
                        .font(ListRowMetrics.accessoryFont)
                        .foregroundStyle(.tertiary)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(.vertical, ListRowMetrics.verticalPadding)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.Interactive.minTapTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ListRowTextView: View {
    let leftText: String
    var rightText: String?
    var rightSymbol: String?

    var body: some View {
        HStack(spacing: ListRowMetrics.contentSpacing) {
            Text(leftText)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.primary)

            Spacer(minLength: ListRowMetrics.minimumTrailingSpacing)

            if let rightText {
                Text(rightText)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            } else if let rightSymbol {
                Image(systemName: rightSymbol)
                    .font(ListRowMetrics.accessoryFont)
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.vertical, ListRowMetrics.verticalPadding)
        .frame(maxWidth: .infinity, minHeight: DesignTokens.Interactive.minTapTarget, alignment: .leading)
        .contentShape(Rectangle())
    }
}
