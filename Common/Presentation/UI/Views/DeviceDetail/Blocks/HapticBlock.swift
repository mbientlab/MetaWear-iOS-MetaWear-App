//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct HapticBlock: View {

    @ObservedObject var vm: HapticSUIVC

    var body: some View {
        OneSectionLayout(
            optionViews: options,
            mainColumn: LabeledItem(
                label: "Use Driver",
                content: drivers
            )
        )
    }

    @ViewBuilder var options: some View {
        LabeledItem(
            label: "Pulse Width",
            content: pulse,
            alignment: .center,
            shouldCompressOnMac: true
        )

        LabeledItem(
            label: "Duty Cycle",
            content: osSpecificDuty,
            shouldCompressOnMac: true
        )
    }

    private var pulse: some View {
        HStack {
            Text("< 10,000 ms")
                .fontVerySmall()
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 6)
                .foregroundColor(.mwSecondary)

            Spacer()

            SmallTextField(smallest: true,
                           initialText: vm.hapticPulseWidthString,
                           placeholder: "500",
                           invalidEntry: false,
                           onCommit: vm.userSetPulseWidth(string:)
            )
        }
    }

    @State private var dutyBinding: Float = 248
    @ViewBuilder private var osSpecificDuty: some View {
#if os(macOS)
        duty
            .controlSize(.small)
            .blendMode(.luminosity)
#else
        HStack {
            Spacer()
            if #available(iOS 15.0, *) {
                duty
                    .controlSize(.small)
                    .blendMode(.luminosity)
            } else {
                duty.blendMode(.luminosity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
#endif
    }

    private var duty: some View {
        HStack {
            Spacer()

            Text(String(format: "%1.0f", dutyBinding))
                .fontBody(monospacedDigit: true)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 10)

            Slider(value: $dutyBinding, in: (0...248)) { _ in
                vm.userSetDutyCycle(cycle: Int(dutyBinding))
            }
            .foregroundColor(Color.gray)
            .accentColor(Color.gray)
            .frame(width: .detailBlockWidth * 0.25)
            .onAppear { dutyBinding = Float(vm.dutyCycle) }
            .onChange(of: vm.dutyCycle) { newValue in dutyBinding = Float(newValue) }
        }
    }

    @State private var hapticAnimation = false
    @State private var buzzerAnimation = false
    private var drivers: some View {
        HStack {
            Spacer()
            Button("Haptic") { vm.userRequestedStartHapticDriver() }
            .modifier(ShakeEffect(shakes: hapticAnimation ? 50 : 0, effectSize: -4))
            Spacer()
            Button("Buzzer") { vm.userRequestedStartBuzzerDriver()  }
            .modifier(ShakeEffect(shakes: buzzerAnimation ? 50 : 0, effectSize: -4))
            Spacer()
        }
        .disabled(!vm.canSendCommand)
        .allowsHitTesting(vm.canSendCommand)
        .opacity(vm.canSendCommand ? 1 : 0.75)
        .animation(.spring().speed(5).repeatCount(2, autoreverses: false), value: hapticAnimation)
        .animation(.spring().speed(5).repeatCount(2, autoreverses: false), value: buzzerAnimation)
        .onChange(of: vm.buzzCount) { _ in buzzerAnimation.toggle() }
        .onChange(of: vm.hapticCount) { _ in hapticAnimation.toggle() }
    }
}
