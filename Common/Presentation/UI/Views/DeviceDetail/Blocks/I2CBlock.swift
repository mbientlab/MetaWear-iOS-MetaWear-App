//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct I2CBlock: View {

    @ObservedObject var vm: I2CBusSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Size",
                content: size
            )

            LabeledItem(
                label: "Device Address",
                content: device,
                alignment: .center,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Register Address",
                content: register,
                alignment: .center,
                contentAlignment: .trailing
            )

            write
            read
        }
    }

    // MARK: - Size

    private var size: some View {
        HStack {

            Spacer()

            Picker("", selection: sizeChoice) {
                ForEach(vm.sizeOptions) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)
#if os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif
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
