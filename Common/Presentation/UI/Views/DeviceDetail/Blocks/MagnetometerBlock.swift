//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MagnetometerBlock: View {

    @ObservedObject var vm: MagnetometerSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LoggingSection()
            DividerPadded()
            LiveInspectorSection()
            
            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .environmentObject(vm)
    }
}

// MARK: - Log

extension MagnetometerBlock {

    struct LoggingSection: View {

        @EnvironmentObject private var vm: MagnetometerSUIVC

        var body: some View {
            LabeledItem(
                label: "Log",
                content: buttons
            )

            if vm.logDataIsReadyForDisplay {

                StatsBlock(stats: vm.loggerStats, count: vm.data.loggedCount)

#if os(iOS)
                AAGraphViewWrapper(initialConfig: vm.makeLoggedDataConfig(),
                                   graph: vm.setLoggerGraphReference)
#endif
            }
        }

        private var buttons: some View {
            HStack(alignment: .firstTextBaseline) {
                let disableLogging = vm.isStreaming || (!vm.isLogging && !vm.allowsNewLogging)

                ExportDataButton(label: "",
                                 isEnabled: vm.logDataIsReadyForDisplay,
                                 action: vm.userRequestedLogExport)

                Spacer()

                DownloadButton(isEnabled: true,
                               onTap: vm.userRequestedDownloadLog)

                Spacer()

                Button(vm.isLogging ? "Stop" : "Log") {
                    if vm.isLogging { vm.userRequestedStopLogging() }
                    else { vm.userRequestedStartLogging() }
                }
                .disabled(disableLogging)
                .allowsHitTesting(!disableLogging)
                .opacity(disableLogging ? 0.5 : 1)
            }
        }

    }

}

// MARK: - Live Stream

extension MagnetometerBlock {

    struct LiveInspectorSection: View {

        let graphID = "MagnetometerGraph"

        @EnvironmentObject private var vm: MagnetometerSUIVC
        @Environment(\.scrollProxy) var scroller

        var body: some View {

            LabeledItem(
                label: "Live",
                content: buttons
            )

            if !vm.data.stream.isEmpty {

                StatsBlock(stats: vm.data.getStreamedStats(), count: vm.data.streamCount)

#if os(iOS)
                AAGraphViewWrapper(initialConfig: vm.makeStreamDataConfig(),
                                   graph: vm.setStreamGraphReference)
                    .id(graphID)
                    .onAppear { scrollToGraph() }

#elseif os(macOS)
                if #available(macOS 12.0, *) {
                    CanvasGraph(controller: .init(stream: vm,
                                                  config: vm.makeStreamDataConfig(),
                                                  driver: ThrottledGraphDriver()),
                                width: calculateGraphWidth())
                        .id(graphID)
                        .onAppear { scrollToGraph() }

                } else {
                    NaiveGraphFixedSize(controller: .init(stream: vm,
                                                          config: vm.makeStreamDataConfig(),
                                                          driver: ThrottledGraphDriver()),
                                        width: calculateGraphWidth())
                        .id(graphID)
                        .onAppear { scrollToGraph() }
                }
#endif
            }
        }

        private func scrollToGraph() {
            withAnimation {
                scroller?.scrollTo(graphID, anchor: .top)
            }
        }

        /// macOS only because on iOS graph width should be defined by the iOS device, not a constant
        private func calculateGraphWidth() -> CGFloat {
            let padding = CGFloat.detailBlockOuterPadding + .detailBlockContentPadding
            let contentWidth = .detailBlockWidth - (padding * 2)
            return contentWidth
        }

        private var buttons: some View {

            HStack(alignment: .firstTextBaseline) {
                let disableStreaming = vm.isLogging || (!vm.isStreaming && !vm.allowsNewStreaming)

                ExportDataButton(label: "",
                                 isEnabled: !vm.isStreaming && !vm.data.stream.isEmpty,
                                 action: vm.userRequestedStreamExport)

                Spacer()

                Button(vm.isStreaming ? "Stop" : "Stream") {
                    if vm.isStreaming { vm.userRequestedStopStreaming() }
                    else { vm.userRequestedStartStreaming() }
                }
                .disabled(disableStreaming)
                .allowsHitTesting(!disableStreaming)
                .opacity(disableStreaming ? 0.5 : 1)
                .overlay(connectionProgress, alignment: .leading)
            }

        }

        @ViewBuilder private var connectionProgress: some View {
            if vm.showStreamingStartupSpinner {
                ProgressView()
                    .progressViewStyle(.circular)
#if os(iOS)
                    .transition(.scale)
#elseif os(macOS)
                    .transition(.opacity)
                    .controlSize(.small)
#endif
                    .offset(x: -35)
            }
        }

    }

}
