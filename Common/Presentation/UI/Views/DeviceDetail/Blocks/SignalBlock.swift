//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SignalBlock: View {

    @ObservedObject var vm: SignalSUIVC

    var body: some View {
        PlatformSpecificTwoColumnNoOptionsLayout(
            leftColumn:
                LabeledItem(label: "RSSI", content: rssi),
            rightColumn:
                LabeledItem(
                    label: "Tx Power",
                    content: txPicker,
                    contentAlignment: .trailing
                )
                .help("Transmit power is only set, not read.")
        )
    }

    // MARK: - RSSI

    private var rssi: some View {
        HStack {
            Text(vm.rssiLevel)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)

            Spacer()

            UpdateButton(
                didTap: vm.userRequestsRSSI,
                helpAccessibilityLabel: "Refresh RSSI"
            )
        }
    }

    // MARK: - Transmit Power

    private var txPicker: some View {
        HStack {
            SmallUnitLabelFixed("Set to")

            MenuPickerWithFixedUnits(
                label: String(vm.transmissionPowerLevels[vm.chosenPowerLevelIndex]),
                binding: txChoice,
                unit: "dBm"
            ) {
                ForEach(vm.indexedTransmissionLevels, id: \.index) {
                    Text(String($0.value)).tag($0.index)
                }
            }
        }
    }

    private var txChoice: Binding<Int> {
        Binding { vm.chosenPowerLevelIndex } set: {
            vm.userChangedTransmissionPower(toIndex: $0)
        }
    }
}
