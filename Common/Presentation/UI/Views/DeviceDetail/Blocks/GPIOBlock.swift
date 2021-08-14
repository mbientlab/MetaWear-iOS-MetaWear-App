//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct GPIOBlock: View {

    @ObservedObject var vm: GPIOSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Pin",
                content: selectPin,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Pull",
                content: configuration
            )

            LabeledItem(
                label: "Digital Out",
                content: digitalOutput
            )

            LabeledItem(
                label: "Type",
                content: pinChangeType,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Pin Changes",
                content: pinChanges
            )

            DividerPadded()

            LabeledItem(
                label: "Digital",
                content: digitalRead
            )

            LabeledItem(
                label: "Analog Absolute",
                content: analogAbsoluteRead
            )

            LabeledItem(
                label: "Analog Ratio",
                content: analogRatioRead
            )
        }
    }

    // MARK: - Pin Change

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

    private var changeType: Binding<GPIOChangeType> {
        Binding { vm.changeType }
        set: { vm.userDidChangeType($0) }
    }

    private var pinChangeType: some View {
        Picker("", selection: changeType) {
            ForEach(vm.changeTypeOptions) {
                Text($0.displayName).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    // MARK: - Pin Change Output

    private var pinChanges: some View {
        HStack {

            Spacer()

            Text(vm.pinChangeCountString)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

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
