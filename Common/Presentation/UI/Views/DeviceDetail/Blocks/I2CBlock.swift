//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct I2CBlock: View {

    @ObservedObject var vm: I2CBusSUIVC

    var body: some View {
        PlatformSpecificOneColumnCardLayout(
            optionViews: options,
            mainColumn: main
        )
    }

    @ViewBuilder private var main: some View {
        write
        read
    }

    @ViewBuilder private var options: some View {
        LabeledItem(
            label: "Size",
            content: size,
            alignment: .bottom,
            contentAlignment: .bottomTrailing,
            shouldCompressOnMac: true
        )

        LabeledItem(
            label: "Device Address",
            content: device,
            contentAlignment: .trailing,
            shouldCompressOnMac: true
        )

        LabeledItem(
            label: "Register Address",
            content: register,
            contentAlignment: .trailing,
            shouldCompressOnMac: true
        )

    }

    // MARK: - Size

    private var size: some View {
        MenuPicker(label: vm.selectedSize.displayName, selection: sizeChoice) {
            ForEach(vm.sizeOptions) {
                Text($0.displayName).tag($0)
            }
        }
    }

    private var sizeChoice: Binding<I2CSize> {
        Binding { vm.selectedSize } set: {
            vm.userSelectedSize($0)
        }
    }

    // MARK: - Text Fields

    private var device: some View {
        SmallTextField(smallest: true,
                       initialText: vm.deviceAddressInput,
                       placeholder: "0x12",
                       invalidEntry: vm.showDeviceInputInvalid,
                       onCommit: vm.userSetDeviceAddress(_:)
        )
    }

    private var register: some View {
        SmallTextField(smallest: true,
                       initialText: vm.deviceRegisterInput,
                       placeholder: "0x34",
                       invalidEntry: vm.showRegisterInputInvalid,
                       onCommit: vm.userSetRegisterAddress(_:)
        )
    }

    private var write: some View {
        HStack {

            Spacer()

            SmallTextField(
                initialText: vm.bytesToWriteInput,
                placeholder: "0xDEADBEEF",
                invalidEntry: vm.showWriteInputInvalid,
                onCommit: vm.userSetBytesToWrite(_:)
            )

            Button("Write") { vm.userRequestedWriteBytes() }
                .fontBody()
        }
    }

    // MARK: - Read Label

    private var read: some View {
        HStack {

            Text(vm.bytesReadFromDeviceOutput)
                .fontBody(design: .monospaced)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Button("Read") { vm.userRequestedReadBytes() }
                .fontBody()
                .multilineTextAlignment(.leading)
        }
    }

}
