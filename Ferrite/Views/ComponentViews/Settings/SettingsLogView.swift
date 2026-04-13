//
//  SettingsLogView.swift
//  Ferrite
//
//  Created by Brian Dashore on 3/8/23.
//

import SwiftUI

struct SettingsLogView: View {
    @EnvironmentObject var logManager: LoggingManager

    private let collapsedLineLimit = 5

    var body: some View {
        List {
            if logManager.messageArray.isEmpty {
                Section {
                    EmptyInstructionView(
                        title: "No Logs Yet",
                        message: "Logs from this session will appear here as Ferrite records activity."
                    )
                    .frame(maxHeight: 220)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    SectionHeaderView(title: "Session Logs", subtitle: "Export or inspect events captured during the current run.")
                }
            }

            if !logManager.messageArray.isEmpty {
                Section {
                    ForEach($logManager.messageArray, id: \.self) { $log in
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                            HStack(spacing: DesignTokens.Spacing.small) {
                                Text("Session Log")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                Spacer(minLength: DesignTokens.Spacing.medium)

                                Image(systemName: log.isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                                    .symbolRenderingMode(.hierarchical)
                            }

                            Text(log.toMessage())
                                .font(.footnote.monospaced())
                                .foregroundStyle(.primary.opacity(0.82))
                                .lineLimit(log.isExpanded ? nil : collapsedLineLimit)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, DesignTokens.Spacing.small)
                        .padding(.horizontal, DesignTokens.Spacing.medium)
                        .contentShape(Rectangle())
                        .liquidGlassCard(tint: Color.primary.opacity(0.02), shadow: false)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            log.isExpanded.toggle()
                        }
                    }
                } header: {
                    SectionHeaderView(title: "Session Logs", subtitle: "Tap any entry to expand or collapse long messages.")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .alert("Success", isPresented: $logManager.showLogExportedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Log successfully exported in Ferrite's logs folder")
        }
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        logManager.exportLogs()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        logManager.messageArray = []
                    } label: {
                        Label("Clear session logs", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

struct SettingsLogView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLogView()
    }
}
