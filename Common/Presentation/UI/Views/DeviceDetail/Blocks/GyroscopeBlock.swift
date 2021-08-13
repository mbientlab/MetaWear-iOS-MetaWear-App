//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct GyroscopeBlock: View {

    @ObservedObject var vm: GyroSUIVC
    @State private var unitLabelWidth = CGFloat(0)

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            ScaleRow(unitLabelWidth: unitLabelWidth)
            SamplingRow(unitLabelWidth: unitLabelWidth)
            DividerPadded()

            LoggingSection()
            DividerPadded()
            LiveInspectorSection()

            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .onPreferenceChange(UnitWidthKey.self) { unitLabelWidth = $0 }
        .environmentObject(vm)
    }
}

// MARK: - Settings

extension GyroscopeBlock {

    struct ScaleRow: View {

        @EnvironmentObject private var vm: GyroSUIVC
        var unitLabelWidth: CGFloat

        private var scaleBinding: Binding<GyroscopeGraphRange> {
            Binding { vm.graphRangeSelected }
            set: { vm.userDidSelectGraphScale($0) }

        }

        var body: some View {
#if os(iOS)
            LabeledItem(label: "Scale",
                        content: picker,
                        alignment: .center,
                        contentAlignment: .trailing)
#elseif os(macOS)
            LabeledItem(label: "Scale",
                        content: macOSLabeledPicker,
                        alignment: .center,
                        contentAlignment: .trailing)
#endif
        }

        private var macOSLabeledPicker: some View {
            HStack {
                picker

                Text("°/s")
                    .fontVerySmall()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
                    .matchWidths(to: GyroscopeBlock.UnitWidthKey.self,
                                 width: unitLabelWidth,
                                 alignment: .leading)
            }
        }

        private var picker: some View {
            Picker(selection: scaleBinding) {
                ForEach(vm.graphRanges) {
                    Text($0.displayName).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.graphRangeSelected.displayName)
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

    struct SamplingRow: View {

        @EnvironmentObject private var vm: GyroSUIVC
        var unitLabelWidth: CGFloat

        private var frequencyBinding: Binding<GyroscopeFrequency> {
            Binding { vm.samplingFrequencySelected }
            set: { vm.userDidSelectSamplingFrequency($0) }
        }

        var body: some View {

#if os(iOS)
            LabeledItem(label: "Sample",
                        content: picker,
                        alignment: .center,
                        contentAlignment: .trailing)
#elseif os(macOS)
            LabeledItem(label: "Sample",
                        content: macosLabeledPicker,
                        alignment: .center,
                        contentAlignment: .trailing)
#endif
        }

        private var macosLabeledPicker: some View {
            HStack {
                picker

                Text("Hz")
                    .fontVerySmall()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
                    .matchWidths(to: GyroscopeBlock.UnitWidthKey.self,
                                 width: unitLabelWidth,
                                 alignment: .leading)
            }
        }

        private var picker: some View {
            Picker(selection: frequencyBinding) {
                ForEach(vm.samplingFrequencies) {
                    Text($0.frequencyLabel).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.samplingFrequencySelected.frequencyLabel + " Hz")
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

private extension GyroscopeBlock {

    struct UnitWidthKey: WidthKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

// MARK: - Log

extension GyroscopeBlock {

    struct LoggingSection: View {

        @EnvironmentObject private var vm: GyroSUIVC

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

extension GyroscopeBlock {

    struct LiveInspectorSection: View {

        let graphID = "GyroscopeGraph"

        @EnvironmentObject private var vm: GyroSUIVC
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
