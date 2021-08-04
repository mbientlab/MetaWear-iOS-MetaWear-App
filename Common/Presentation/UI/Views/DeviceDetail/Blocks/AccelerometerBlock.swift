//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AccelerometerBlock: View {

    @ObservedObject var vm: MWAccelerometerSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "Orientation",
                content: orientation
            )

            LabeledItem(
                label: "Step Detection",
                content: steps
            )

            LabeledItem(
                label: "Scale",
                content: scale
            )

            LabeledItem(
                label: "Sampling (Hz)",
                content: scale
            )

            LabeledItem(
                label: "Accelerometer",
                content: accelerometer
            )

            if vm.canExportData {
                VStack {
                    APLGraphViewWrapper(vm: vm)

                    ExportDataButton(isEnabled: vm.canExportData,
                                     action: vm.userRequestedDataExport)
                }
            }
        }
    }

    var scaleBinding: Binding<AccelerometerGraphScale> {
        Binding { vm.graphScaleSelected }
        set: { vm.userDidSelectGraphScale($0) }

    }

    var scale: some View {
        Picker("", selection: scaleBinding) {
            ForEach(vm.graphScales) {
                Text(vm.graphScaleLabel($0)).tag($0.id)
            }
        }
    }

    var frequencyBinding: Binding<AccelerometerSampleFrequency> {
        Binding { vm.samplingFrequencySelected }
        set: { vm.userDidSelectSamplingFrequency($0) }

    }

    var frequency: some View {
        Picker("", selection: frequencyBinding) {
            ForEach(vm.samplingFrequencies) {
                Text($0.frequencyLabel).tag($0.id)
            }
        }
    }


    var steps: some View {
        HStack {
            Button(vm.isStepping ? "Stop" : "Count") {
                if vm.isStepping { vm.userRequestedStopStepping() }
                else { vm.userRequestedStartStepping() }
            }
            Spacer()
            Image(systemName: SFSymbol.steps.rawValue)
                .accessibilityLabel(SFSymbol.steps.accessibilityDescription)
            Text(String(vm.stepCount))
                .accessibilityValue(Text("\(vm.stepCount) Steps"))
        }
    }

    var orientation: some View {
        HStack {
            Button(vm.isOrienting ? "Stop" : "Monitor") {
                if vm.isOrienting { vm.userRequestedStopOrienting() }
                else { vm.userRequestedStartOrienting() }
            }
            Spacer()
            Text(String(vm.orientation))
                .accessibilityValue(Text(vm.orientation))
        }
    }

    var accelerometer: some View {

        VStack {
            let disableStreaming = vm.isLogging || (!vm.isStreaming && !vm.allowsNewStreaming)
            let disableLogging = vm.isStreaming || (!vm.isLogging && !vm.allowsNewLogging)

            Button(vm.isStreaming ? "Stop Streaming" : "Stream") {
                if vm.isOrienting { vm.userRequestedStopOrienting() }
                else { vm.userRequestedStartOrienting() }
            }
            .disabled(disableStreaming)
            .allowsHitTesting(!disableStreaming)
            .opacity(disableStreaming ? 0.5 : 1)

            Spacer()

            Button(vm.isLogging ? "Stop Logging" : "Log") {
                if vm.isOrienting { vm.userRequestedStopOrienting() }
                else { vm.userRequestedStartOrienting() }
            }
            .disabled(disableLogging)
            .allowsHitTesting(!disableLogging)
            .opacity(disableLogging ? 0.5 : 1)
        }

    }

}
