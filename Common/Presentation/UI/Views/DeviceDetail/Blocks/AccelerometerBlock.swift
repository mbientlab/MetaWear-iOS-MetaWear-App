//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AccelerometerBlock: View {
    
    @ObservedObject var vm: AccelerometerSUIVC
    
    var body: some View {
        VStack(spacing: .cardVSpacing) {
            
            ScaleRow()
            SamplingRow()
            DividerPadded()

            OrientationAndStepsRows()
            DividerPadded()

            LoggingSection()
            DividerPadded()
            
            LiveInspectorSection()
        }
        .environmentObject(vm)
    }
}

// MARK: - Live Inspector
extension AccelerometerBlock {

    struct LiveInspectorSection: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC
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
                    .id("AccelerometerGraph")
                    .onAppear { scrollToGraph() }

#elseif os(macOS)
                if #available(macOS 12.0, *) {
                    CanvasGraph(controller: .init(stream: vm,
                                                  config: vm.makeStreamDataConfig(),
                                                  driver: ThrottledGraphDriver()),
                                width: calculateGraphWidth())
                        .id("AccelerometerGraph")
                        .onAppear { scrollToGraph() }

                } else {
                    NaiveGraphFixedSize(controller: .init(stream: vm,
                                                          config: vm.makeStreamDataConfig(),
                                                          driver: ThrottledGraphDriver()),
                                        width: calculateGraphWidth())
                        .id("AccelerometerGraph")
                        .onAppear { scrollToGraph() }
                }
#endif
            }
        }

        private func scrollToGraph() {
            withAnimation {
                scroller?.scrollTo("AccelerometerGraph", anchor: .top)
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

// MARK: - Logging
extension AccelerometerBlock {

    struct LoggingSection: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC

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

// MARK: - Options & Single Line Feeds
extension AccelerometerBlock {

    struct OrientationAndStepsRows: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC

        var body: some View {
            LabeledItem(
                label: "Orientation",
                content: orientation
            )

            LabeledItem(
                label: "Steps",
                content: steps
            )
        }

        private var steps: some View {
            HStack {
                if vm.isStepping || vm.stepCount != 0 {
                    Text(String(vm.stepCount))
                        .accessibilityValue(Text("\(vm.stepCount) Steps"))
                        .frame(maxWidth: .infinity, alignment: .center)
                } else { Spacer() }

                Button(vm.isStepping ? "Stop" : "Stream") {
                    if vm.isStepping { vm.userRequestedStopStepping() }
                    else { vm.userRequestedStartStepping() }
                }
            }
        }

        private var orientation: some View {
            HStack {
                Text(String(vm.orientation))
                    .accessibilityValue(Text(vm.orientation))
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(vm.isOrienting ? "Stop" : "Stream") {
                    if vm.isOrienting { vm.userRequestedStopOrienting() }
                    else { vm.userRequestedStartOrienting() }
                }
            }
        }
    }

    struct ScaleRow: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC

        var body: some View {
            LabeledItem(label: "Scale", content: scale)
        }

        private var scaleBinding: Binding<AccelerometerGraphScale> {
            Binding { vm.graphScaleSelected }
            set: { vm.userDidSelectGraphScale($0) }

        }

        private var scale: some View {
            Picker(selection: scaleBinding) {
                ForEach(vm.graphScales) {
                    Text(vm.graphScaleLabel($0)).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.graphScaleLabel(vm.graphScaleSelected))
#endif
            }
            .contentShape(Rectangle())
#if os(iOS)
            .pickerStyle(.menu)
#elseif os(macOS)
            .pickerStyle(.segmented)
#endif
            .frame(maxWidth: .infinity, alignment: .trailing)
        }

    }

    struct SamplingRow: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC

        var body: some View {
            LabeledItem(label: "Sample", content: osDependentContent)
        }

        private var frequencyBinding: Binding<AccelerometerSampleFrequency> {
            Binding { vm.samplingFrequencySelected }
            set: { vm.userDidSelectSamplingFrequency($0) }
        }

        private var osDependentContent: some View {
#if os(iOS)
            frequency
#elseif os(macOS)
            HStack {
                frequency

                Text("Hz")
                    .fontVerySmall()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
            }
#endif
        }

        private var frequency: some View {
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
            .frame(maxWidth: .infinity, alignment: .trailing)
#if os(macOS)
            .accentColor(.gray) // Only override for macOS styling
#endif
        }
    }
}
