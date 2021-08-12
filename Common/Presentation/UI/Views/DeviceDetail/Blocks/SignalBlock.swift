//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SignalBlock: View {

    @ObservedObject var vm: SignalSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "RSSI",
                content: rssi
            )

            LabeledItem(
                label: "Tx Power",
                content: txPicker,
                contentAlignment: .trailing
            )
        }
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
            Picker(txLabel, selection: txChoice) {
                ForEach(vm.indexedTransmissionLevels, id: \.index) {
                    Text(String($0.value)).tag($0.index)
                }
            }
            .pickerStyle(.menu)
#if os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif

#if os(macOS)
            Text("dBm")
                .fontVerySmall()
                .foregroundColor(.secondary)
                .padding(.leading, 5)
#endif
        }
    }

    private var txChoice: Binding<Int> {
        Binding { vm.chosenPowerLevelIndex } set: {
            vm.userChangedTransmissionPower(toIndex: $0)
        }
    }

    private var txLabel: String {
#if os(iOS)
        "\(vm.transmissionPowerLevels[vm.chosenPowerLevelIndex]) dBm"
#else
        ""
#endif
    }
}
