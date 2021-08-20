//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AccelerometerBlock: View {
    
    @ObservedObject var vm: AccelerometerSUIVC

    @State private var unitWidth = CGFloat(0)

    var body: some View {
        if vm.canOrientOrStep {
            PlatformSpecificExtraRowCardLayout(
                optionViews: options,
                otherViews: OrientationAndStepsRows(),
                leftColumn: LoggingSectionStandardized(vm: vm),
                rightColumn: LiveStreamSection(scrollViewGraphID: "AccelStreamGraph", vm: vm)
            )
                .onPreferenceChange(UnitWidthKey.self) { unitWidth = $0 }
                .environmentObject(vm)

        } else {

            PlatformSpecificTwoColumnCardLayout(
                optionViews: options,
                leftColumn: LoggingSectionStandardized(vm: vm),
                rightColumn: LiveStreamSection(scrollViewGraphID: "AccelStreamGraph", vm: vm)
            )
                .onPreferenceChange(UnitWidthKey.self) { unitWidth = $0 }
                .environmentObject(vm)
        }

    }

    @ViewBuilder private var options: some View {
        ScaleRow(unitWidth: unitWidth)
        SamplingRow(unitWidth: unitWidth)
    }
}

// MARK: - Single Line Feeds
extension AccelerometerBlock {

    struct OrientationAndStepsRows: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC

        var body: some View {
            LabeledItem(
                label: "Orientation",
                content: orientation
            )

#if os(macOS)
            VerticalDivider()
#endif

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

    // MARK: - Options

    struct ScaleRow: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC
        var unitWidth: CGFloat

        var body: some View {
            LabeledItem(label: "Scale",
                        content: scale,
                        contentAlignment: .trailing,
                        shouldCompressOnMac: true
            )
        }

        private var scaleBinding: Binding<AccelerometerGraphScale> {
            Binding { vm.graphScaleSelected }
            set: { vm.userDidSelectGraphScale($0) }

        }

        private var scale: some View {
            MenuPickerWithUnitsAligned(
                label: vm.graphScaleLabel(vm.graphScaleSelected),
                binding: scaleBinding,
                unit: "G",
                unitWidthKey: UnitWidthKey.self,
                unitWidth: unitWidth) {
                    ForEach(vm.graphScales) {
                        Text(vm.graphScaleLabel($0)).tag($0)
                    }
                }
        }
    }

    struct SamplingRow: View {

        @EnvironmentObject private var vm: AccelerometerSUIVC
        var unitWidth: CGFloat

        var body: some View {
            LabeledItem(
                label: "Frequency",
                content: picker,
                contentAlignment: .trailing,
                shouldCompressOnMac: true
            )
        }

        private var frequencyBinding: Binding<AccelerometerSampleFrequency> {
            Binding { vm.samplingFrequencySelected }
            set: { vm.userDidSelectSamplingFrequency($0) }
        }

        private var picker: some View {
            MenuPickerWithUnitsAligned(
                label: vm.samplingFrequencySelected.frequencyLabel,
                binding: frequencyBinding,
                unit: "Hz",
                unitWidthKey: UnitWidthKey.self,
                unitWidth: unitWidth) {

                    ForEach(vm.samplingFrequencies) {
                        Text($0.frequencyLabel).tag($0)
                    }
                }
        }
    }
}

private extension AccelerometerBlock {

    struct UnitWidthKey: WidthKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
