//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AccelerometerBlock: View {
    
    @ObservedObject var vm: MWAccelerometerSVC
    
    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "Orientation",
                content: orientation
            )
            
            LabeledItem(
                label: "Steps",
                content: steps
            )

            DividerPadded()
            
            LabeledItem(
                label: "Scale",
                content: scale
            )
            
            LabeledItem(
                label: "Sample",
                content: frequency
            )
            
            LabeledItem(
                label: "Sensor",
                content: accelerometer
            )
            
            if vm.canExportData {

                //                    APLGraphViewWrapper(vm: vm)

                DividerPadded()

                LabeledItem(
                    label: "Data",
                    content: dataExport
                )

            }
        }
    }

    
    var steps: some View {
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
    
    var orientation: some View {
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

    // MARK: - Settings

    var scaleBinding: Binding<AccelerometerGraphScale> {
        Binding { vm.graphScaleSelected }
        set: { vm.userDidSelectGraphScale($0) }

    }

    var scale: some View {
        Picker(vm.graphScaleLabel(vm.graphScaleSelected), selection: scaleBinding) {
            ForEach(vm.graphScales) {
                Text(vm.graphScaleLabel($0)).tag($0)
            }
        }
        .contentShape(Rectangle())
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    var frequencyBinding: Binding<AccelerometerSampleFrequency> {
        Binding { vm.samplingFrequencySelected }
        set: { vm.userDidSelectSamplingFrequency($0) }

    }

    var frequency: some View {
        Picker(vm.samplingFrequencySelected.frequencyLabel + " Hz", selection: frequencyBinding) {
            ForEach(vm.samplingFrequencies) {
                Text($0.frequencyLabel).tag($0)
            }
        }
        .contentShape(Rectangle())
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - Accelerometer & Data
    
    var accelerometer: some View {
        
        HStack {
            let disableStreaming = vm.isLogging || (!vm.isStreaming && !vm.allowsNewStreaming)
            let disableLogging = vm.isStreaming || (!vm.isLogging && !vm.allowsNewLogging)
            
            Button(vm.isStreaming ? "Stop Streaming" : "Stream") {
                if vm.isStreaming { vm.userRequestedStopStreaming() }
                else { vm.userRequestedStartStreaming() }
            }
            .disabled(disableStreaming)
            .allowsHitTesting(!disableStreaming)
            .opacity(disableStreaming ? 0.5 : 1)
            
            Spacer()
            
            Button(vm.isLogging ? "Get Log" : "Log") {
                if vm.isLogging { vm.userRequestedStopAndDownloadLog() }
                else { vm.userRequestedStartLogging() }
            }
            .disabled(disableLogging)
            .allowsHitTesting(!disableLogging)
            .opacity(disableLogging ? 0.5 : 1)
        }
        
    }

    var dataExport: some View {
        HStack {

            Text(String(vm.dataPoints))
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            ExportDataButton(isEnabled: vm.canExportData,
                             action: vm.userRequestedDataExport)
        }
    }
    
}
