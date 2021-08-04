//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct FirmwareBlock: View {

    @ObservedObject var vm: MWFirmwareSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "Firmware Rev",
                content: firmware
            )

            LabeledItem(
                label: vm.offerUpdate ? "New Firmware" : "Status",
                content: status
            )

            if vm.offerUpdate {
                Button("Update Firmware") { vm.userRequestedUpdateFirmware() }
            }
        }
    }

    var firmware: some View {
        Text(vm.firmwareRevision)
    }

    var status: some View {
        HStack {
            Text(vm.firmwareUpdateStatus)
            Spacer()
            UpdateButton(didTap: vm.userRequestedCheckForFirmwareUpdates,
                         helpAccessibilityLabel: "Check Firmware Version")
        }
    }
}
