//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SignalBlock: View {

    @ObservedObject var vm: MWSignalSVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "RSSI",
                content: rssi
            )

            LabeledItem(
                label: "Tx Power",
                content: tx
            )
        }
    }

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

    private var txChoice: Binding<Int> {
        Binding { vm.chosenPowerLevelIndex } set: {
            vm.userChangedTransmissionPower(toIndex: $0)
        }
    }

    private var tx: some View {
        HStack {
            Picker("\(vm.transmissionPowerLevels[vm.chosenPowerLevelIndex]) dBm", selection: txChoice) {
                ForEach(vm.indexedTransmissionLevels, id: \.index) {
                    Text(String($0.value)).tag($0.index)
                }
            }
            .pickerStyle(.menu)
            .fixedSize()
        }
    }
}
