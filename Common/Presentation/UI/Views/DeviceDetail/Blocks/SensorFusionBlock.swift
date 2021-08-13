//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SensorFusionBlock: View {

    @ObservedObject var vm: SensorFusionSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            ScaleRow()
            OutputType()
            DividerPadded()

            LoggingSection()
            DividerPadded()
            LiveInspectorSection()

            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .environmentObject(vm)
    }
}

// MARK: - Settings

extension SensorFusionBlock {

    struct ScaleRow: View {

        @EnvironmentObject private var vm: SensorFusionSUIVC

        private var binding: Binding<SensorFusionMode> {
            Binding { vm.selectedFusionMode }
            set: { vm.userSetFusionMode($0) }

        }

        var body: some View {
            LabeledItem(label: "Mode",
                        content: picker,
                        alignment: .center,
                        contentAlignment: .trailing)
        }

        private var picker: some View {
            Picker(selection: binding) {
                ForEach(vm.fusionModes) {
                    Text($0.displayName).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.selectedFusionMode.displayName)
#endif
            }
            .contentShape(Rectangle())
            .pickerStyle(.menu)
#if os(iOS)
            .frame(maxWidth: .infinity, alignment: .trailing)
#elseif os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif
        }
    }

    struct OutputType: View {

        @EnvironmentObject private var vm: SensorFusionSUIVC

        private var binding: Binding<SensorFusionOutputType> {
            Binding { vm.selectedOutputType }
            set: { vm.userSetOutputType($0) }
        }

        var body: some View {
            LabeledItem(label: "Output",
                        content: picker,
                        alignment: .center,
                        contentAlignment: .trailing)
        }

        private var picker: some View {
            Picker(selection: binding) {
                ForEach(vm.outputTypes) {
                    Text($0.fullName).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.selectedOutputType.fullName)
#endif
            }
            .contentShape(Rectangle())
            .pickerStyle(.menu)
#if os(iOS)
            .frame(maxWidth: .infinity, alignment: .trailing)
#elseif os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif
        }
    }
}

// MARK: - Log

extension SensorFusionBlock {

    struct LoggingSection: View {

        @EnvironmentObject private var vm: SensorFusionSUIVC

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

extension SensorFusionBlock {

    struct LiveInspectorSection: View {

        let graphID = "SensorFusionGraph"

        @EnvironmentObject private var vm: SensorFusionSUIVC
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
