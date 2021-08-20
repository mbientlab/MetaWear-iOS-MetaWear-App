//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct GPIOBlock: View {

    @ObservedObject var vm: GPIOSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Mode",
                content: selectMode,
                contentAlignment: .trailing
            )

            DividerPadded()

            analogOrDigitalPinOperations

            DividerPadded()

            analogOrDigitalOutputs

        }
        .animation(.easeOut, value: vm.mode)
    }

    // MARK: - Mode

    private var modeSelected: Binding<GPIOMode> {
        Binding { vm.mode }
        set: { vm.userDidSelectMode($0) }
    }

    private var selectMode: some View {
        Picker("", selection: modeSelected) {
            ForEach(vm.modes) {
                Text($0.displayName).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    // MARK: - Pin Change

    @ViewBuilder private var analogOrDigitalPinOperations: some View {

        LabeledItem(
            label: "Pin",
            content: selectPin,
            contentAlignment: .trailing
        )

        if vm.mode == .analog {
            LabeledItem(
                label: "Pull",
                content: configuration
                    .opacity(vm.isChangingPins ? 1 : 0.2)
                    .allowsHitTesting(vm.isChangingPins)
                    .disabled(!vm.isChangingPins)
            )
        }

        if vm.mode == .digital {
            LabeledItem(
                label: "Digital",
                content: digitalOutput
                    .opacity(vm.isChangingPins ? 1 : 0.2)
                    .allowsHitTesting(vm.isChangingPins)
                    .disabled(!vm.isChangingPins)
            )
        }

        LabeledItem(
            label: "Changes",
            content: pinChanges
        )
    }

    private var pinSelected: Binding<GPIOPin> {
        Binding { vm.pinSelected }
        set: { vm.userDidSelectPin($0) }
    }

    private var selectPin: some View {
        Picker("", selection: pinSelected) {
            ForEach(vm.pins) {
                Text($0.displayName).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    // Mark: - Mode-specific Changes

    private var configuration: some View {
        HStack {
            Spacer()
            Button("Up") { vm.userDidPressPull(.up) }
            Spacer()
            Button("Down") { vm.userDidPressPull(.down) }
            Spacer()
            Button("None") { vm.userDidPressPull(.pullNone) }
            Spacer()
        }
    }

    private var digitalOutput: some View {
        HStack {
            Spacer()
            Button("Set") { vm.userPressedSetPin() }
            Spacer()
            Button("Clear") { vm.userPressedClearPin() }
            Spacer()
        }
    }

    // MARK: - Pin Change Output

    private var pinChanges: some View {
        HStack {

            Text(vm.pinChangeCountString)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            if vm.mode == .analog, vm.isChangingPins {
                Text(vm.changeType.displayName)
            }

            Spacer()

            Button(vm.isChangingPins ? "Stop" : "Start") {
                if vm.isChangingPins {
                    vm.userRequestedPinChangeStop()
                } else {
                    vm.userRequestedPinChangeStart()
                }
            }
        }
    }


    // MARK: - Reads

    @ViewBuilder private var analogOrDigitalOutputs: some View {
        if vm.mode == .analog {

            LabeledItem(
                label: "Absolute",
                content: analogAbsoluteRead
            )

            LabeledItem(
                label: "Ratio",
                content: analogRatioRead
            )
        }

        if vm.mode == .digital {
            LabeledItem(
                label: "Readout",
                content: digitalRead
            )
        }
    }

    private var digitalRead: some View {
        HStack {
            Text(vm.digitalValue)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            UpdateButton(didTap: vm.userRequestedDigitalReadout,
                         helpAccessibilityLabel: "Read Digital")
        }
    }

    private var analogAbsoluteRead: some View {
        HStack {
            Text(vm.analogAbsoluteValue)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            UpdateButton(didTap: vm.userRequestedAnalogAbsoluteReadout,
                         helpAccessibilityLabel: "Read Analog Absolute")
        }
    }

    private var analogRatioRead: some View {
        HStack {
            Text(vm.analogRatioValue)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            UpdateButton(didTap: vm.userRequestedAnalogRatioReadout,
                         helpAccessibilityLabel: "Read Analog Ratio")
        }
    }
}
