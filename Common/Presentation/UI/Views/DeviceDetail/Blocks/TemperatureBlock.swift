//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct TemperatureBlock: View {

    @ObservedObject var vm: TemperatureSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "Reported",
                content: temp
            )

            LabeledItem(
                label: "Type",
                content: channelType
            )

            LabeledItem(
                label: "Channel",
                content: channel
            )

            if vm.showPinDetail {
                LabeledItem(
                    label: "Read Pin",
                    content: read
                )

                LabeledItem(
                    label: "Enable Pin",
                    content: enable
                )
            }
        }
        .animation(.easeOut, value: vm.showPinDetail)
    }

    private var channelBinding: Binding<Int> {
        Binding { vm.selectedChannelIndex }
        set: { vm.selectChannel(at: $0) }

    }

    private var channel: some View {
        Picker(selection: channelBinding, label: EmptyView()) {
            ForEach(vm.channelsIndexed, id: \.index) {
                Text($0.label).tag($0.index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var temp: some View {
        HStack {
            Text(vm.temperature)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            UpdateButton(didTap: vm.readTemperature,
                         helpAccessibilityLabel: "Read Temperature")
        }
    }

    private var channelType: some View {
        Text(vm.selectedChannelType)
    }

    // MARK: - External Thermistor

    private var readBinding: Binding<GPIOPin> {
        Binding { vm.readPin }
        set: { vm.setReadPin($0) }

    }

    private var read: some View {
        Picker(selection: readBinding, label: EmptyView()) {
            ForEach(GPIOPin.allCases) {
                Text($0.displayName).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var enableBinding: Binding<GPIOPin> {
        Binding { vm.enablePin }
        set: { vm.setEnablePin($0) }

    }

    private var enable: some View {
        Picker(selection: enableBinding, label: EmptyView()) {
            ForEach(GPIOPin.allCases) {
                Text($0.displayName).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
