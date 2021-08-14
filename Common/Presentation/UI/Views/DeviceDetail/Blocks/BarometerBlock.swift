//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct BarometerBlock: View {

    @ObservedObject var vm: BarometerSUIVC

    @State private var unitWidth = CGFloat(0)
    @State private var read = ""
    @State private var enable = ""

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Oversampling",
                content: oversampling,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Averaging",
                content: averaging,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Standby Time",
                content: standbyTime,
                contentAlignment: .trailing
            )

            DividerPadded()

            LabeledItem(
                label: "Altitude",
                content: stream
            )
        }
        .onPreferenceChange(UnitWidthKey.self) { unitWidth = $0 }
    }

    // MARK: - Picker Bindings

    private var oversamplingBinding: Binding<BarometerOversampling> {
        Binding { vm.oversamplingSelected }
            set: { vm.userSetOversampling($0) }
    }

    private var averagingBinding: Binding<BarometerIIRFilter> {
        Binding { vm.iirFilterSelected }
            set: { vm.userSetIIRFilter($0) }
    }

    private var standbyTimeBinding: Binding<BarometerStandbyTime> {
        Binding { vm.standbyTimeSelected }
            set: { vm.userSetStandbyTime($0) }
    }

    // MARK: - Pickers

    private var oversampling: some View {
        MenuPicker(label: vm.oversamplingSelected.displayName,
                   selection: oversamplingBinding) {
            ForEach(vm.oversamplingOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    private var averaging: some View {
        MenuPickerWithUnitsAligned(
            label: vm.iirFilterSelected.displayName,
            binding: averagingBinding,
            unit: "x",
            unitWidthKey: UnitWidthKey.self,
            unitWidth: unitWidth
        ) {
            ForEach(vm.iirTimeOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    private var standbyTime: some View {
        MenuPickerWithUnitsAligned(
            label: vm.standbyTimeSelected.displayName,
            binding: standbyTimeBinding,
            unit: "ms",
            unitWidthKey: UnitWidthKey.self,
            unitWidth: unitWidth
        ) {
            ForEach(vm.standbyTimeOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    // MARK: - Streaming

    private var stream: some View {
        HStack {
            Text(vm.altitudeString)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            SmallUnitLabelFixed("m")
                .opacity(vm.altitudeString.isEmpty ? 0 : 1)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Stream") {
                if vm.isStreaming { vm.userRequestedStreamStop() }
                else { vm.userRequestedStreamStart() }
            }
        }
    }
}

private extension BarometerBlock {

    struct UnitWidthKey: WidthKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
