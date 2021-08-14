//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AmbientLightBlock: View {

    @ObservedObject var vm: AmbientLightSUIVC

    @State private var read = ""
    @State private var enable = ""
    @State private var unitWidth = CGFloat(0)

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Gain",
                content: gain,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Integration Time",
                content: integration,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Sampling Rate",
                content: measurement,
                contentAlignment: .trailing
            )

            DividerPadded()

            LabeledItem(
                label: "Live",
                content: stream
            )
        }
        .onPreferenceChange(UnitWidthKey.self) { unitWidth = $0 }
    }

    // MARK: - Pickers

    private var gainBinding: Binding<AmbientLightGain> {
        Binding { vm.gainSelected }
        set: { vm.userSetGain($0) }
    }

    private var gain: some View {
        MenuPickerWithUnitsAligned(
            label: vm.gainSelected.displayName,
            binding: gainBinding,
            unit: "x",
            unitWidthKey: UnitWidthKey.self,
            unitWidth: unitWidth
        ) {
            ForEach(vm.gainOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    private var integrationBinding: Binding<AmbientLightTR329IntegrationTime> {
        Binding { vm.integrationTimeSelected }
        set: { vm.userSetIntegrationTime($0) }
    }

    private var integration: some View {
        MenuPickerWithUnitsAligned(
            label: vm.integrationTimeSelected.displayName,
            binding: integrationBinding,
            unit: "ms",
            unitWidthKey: UnitWidthKey.self,
            unitWidth: unitWidth
        ) {
            ForEach(vm.integrationTimeOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    private var measurementBinding: Binding<AmbientLightTR329MeasurementRate> {
        Binding { vm.measurementRateSelected }
        set: { vm.userSetMeasurementRate($0) }
    }

    private var measurement: some View {
        MenuPickerWithUnitsAligned(
            label: vm.measurementRateSelected.displayName,
            binding: measurementBinding,
            unit: "ms",
            unitWidthKey: UnitWidthKey.self,
            unitWidth: unitWidth
        ) {
            ForEach(vm.measurementRateOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    // MARK: - Streaming

    private var stream: some View {
        HStack {
            Text(vm.illuminanceString)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            SmallUnitLabelFixed("lux")
                .opacity(vm.illuminanceString.isEmpty ? 0 : 1)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Stream") {
                if vm.isStreaming { vm.userRequestedStreamStop() }
                else { vm.userRequestedStreamStart() }
            }
        }
    }
}

private extension AmbientLightBlock {

    struct UnitWidthKey: WidthKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
