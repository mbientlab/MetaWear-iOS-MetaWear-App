//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AccelerometerBlock: View {
    
    @ObservedObject var vm: MWAccelerometerSVC
    
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

        @EnvironmentObject private var vm: MWAccelerometerSVC

        var body: some View {

            LabeledItem(
                label: "Live",
                content: buttons
            )

            if !vm.data.stream.isEmpty {

                StatsBlock(stats: vm.data.getStreamedStats(), count: vm.data.streamCount)

                AAGraphViewWrapper(initialConfig: vm.makeStreamDataConfig(),
                                   graph: vm.setStreamGraphReference)

            }
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
                ProgressView().progressViewStyle(.circular)
                    .transition(.scale)
                    .offset(x: -35)
            }
        }

    }

}

// MARK: - Logging
extension AccelerometerBlock {

    struct LoggingSection: View {

        @EnvironmentObject private var vm: MWAccelerometerSVC

        var body: some View {
            LabeledItem(
                label: "Log",
                content: buttons
            )

            if vm.logDataIsReadyForDisplay {

                StatsBlock(stats: vm.streamingStats, count: vm.data.loggedCount)

                AAGraphViewWrapper(initialConfig: vm.makeLoggedDataConfig(),
                                   graph: vm.setLoggerGraphReference)

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

        @EnvironmentObject private var vm: MWAccelerometerSVC

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

        @EnvironmentObject private var vm: MWAccelerometerSVC

        var body: some View {
            LabeledItem(label: "Scale", content: scale)
        }

        private var scaleBinding: Binding<AccelerometerGraphScale> {
            Binding { vm.graphScaleSelected }
            set: { vm.userDidSelectGraphScale($0) }

        }

        private var scale: some View {
            Picker(vm.graphScaleLabel(vm.graphScaleSelected), selection: scaleBinding) {
                ForEach(vm.graphScales) {
                    Text(vm.graphScaleLabel($0)).tag($0)
                }
            }
            .contentShape(Rectangle())
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    struct SamplingRow: View {

        @EnvironmentObject private var vm: MWAccelerometerSVC

        var body: some View {
            LabeledItem(label: "Sample", content: frequency)
        }

        private var frequencyBinding: Binding<AccelerometerSampleFrequency> {
            Binding { vm.samplingFrequencySelected }
            set: { vm.userDidSelectSamplingFrequency($0) }

        }

        private var frequency: some View {
            Picker(vm.samplingFrequencySelected.frequencyLabel + " Hz", selection: frequencyBinding) {
                ForEach(vm.samplingFrequencies) {
                    Text($0.frequencyLabel).tag($0)
                }
            }
            .contentShape(Rectangle())
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
