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

            LoggingSectionStandardized(vm: vm)
            DividerPadded()
            LiveStreamSection(scrollViewGraphID: "AccelStreamGraph", vm: vm)
        }
        .environmentObject(vm)
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
