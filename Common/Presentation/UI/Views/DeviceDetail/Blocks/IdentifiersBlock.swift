//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct IdentifiersBlock: View {

    @ObservedObject var vm: IdentifiersSUIVC
    @ObservedObject var firmware: FirmwareSUIVC
    @ObservedObject var battery: BatterySUIVC

    var body: some View {
        PlatformSpecificTwoColumnNoOptionsLayout(
            leftColumn: hardwareColumn,
            rightColumn: firmwareColumn
        )
    }

    // MARK: - Firmware

    @ViewBuilder private var firmwareColumn: some View {

        LabeledItem(
            label: "Battery",
            content: batteryRow
        )

        LabeledItem(
            label: "Firmware",
            content: Text(firmware.firmwareRevision)
        )

        LabeledItem(
            label: firmware.offerUpdate ? "New Firmware" : "Status",
            content: firmwareStatus
        )

        if firmware.offerUpdate {
            Button("Update Firmware") { firmware.userRequestedUpdateFirmware() }
        }
    }

    private var firmwareStatus: some View {
        HStack {
            Text(firmware.firmwareUpdateStatus)
            Spacer()
            UpdateButton(didTap: firmware.userRequestedCheckForFirmwareUpdates,
                         helpAccessibilityLabel: "Check Firmware Version")
        }
    }

    // MARK: - Battery

    private var batteryRow: some View {
        HStack(spacing: .cardVSpacing) {

            Text("\(battery.batteryLevelPercentage)%")
                .foregroundColor(color)
                .fontWeight(.medium)
                .fontSmall(weight: .medium)
                .padding(.trailing, 8)

            ProgressView("", value: Float(battery.batteryLevelPercentage), total: Float(100))
                .progressViewStyle(LinearProgressViewStyle(tint: .gray))
                .accessibilityValue(String("\(battery.batteryLevelPercentage)%"))
                .accentColor(color)
                .foregroundColor(color)
                .opacity(battery.batteryLevelPercentage > 40 ? 0.75 : 1)
                .offset(y: -8)
                .accessibilityHidden(true)

            Spacer()

            UpdateButton(didTap: battery.userRequestedBatteryLevel, helpAccessibilityLabel: "Refresh Battery Level")
        }
    }

    private var color: Color {
        battery.batteryLevelPercentage > 40 ? Color.primary : Color(.systemPink)
    }

    // MARK: - Hardware

    @ViewBuilder private var hardwareColumn: some View {
        LabeledItem(
            label: "OEM",
            content: manufacturer
        )

        LabeledItem(
            label: "Model",
            content: model
        )

        LabeledItem(
            label: "Serial",
            content: serial
        )

        LabeledItem(
            label: "Hardware",
            content: hardware
        )
    }

    private var manufacturer: some View {
        Text(vm.manufacturer)
    }

    private var model: some View {
        Text(vm.modelNumber)
    }

    private var serial: some View {
        Text(vm.serialNumber)
    }

    private var hardware: some View {
        Text(vm.harwareRevision)
    }
}
