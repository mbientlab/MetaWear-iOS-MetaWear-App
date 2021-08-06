//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct LEDBlock: View {

    @ObservedObject var vm: MWLEDSVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "Steady",
                content: steady
            )

            DividerPadded()

            LabeledItem(
                label: "Flash",
                content: flash
            )

            DividerPadded()

            LabeledItem(
                label: "",
                content: off
            )
        }
    }

    private var steady: some View {
        HStack {
            ColorButton(symbol: .solidCircle,
                        label: "Red",
                        color: Color(.systemRed),
                        onPress: vm.turnOnRed
            )

            Spacer()

            ColorButton(symbol: .solidCircle,
                        label: "Green",
                        color: Color(.systemGreen),
                        onPress: vm.turnOnGreen
            )

            Spacer()

            ColorButton(symbol: .solidCircle,
                        label: "Blue",
                        color: Color(.systemBlue),
                        onPress: vm.turnOnBlue
            )
        }
    }

    private var flash: some View {
        HStack {
            ColorButton(symbol: .flash,
                        label: "Red",
                        color: Color(.systemRed),
                        onPress: vm.flashRed
            )

            Spacer()

            ColorButton(symbol: .flash,
                        label: "Green",
                        color: Color(.systemGreen),
                        onPress: vm.flashGreen
            )

            Spacer()

            ColorButton(symbol: .flash,
                        label: "Blue",
                        color: Color(.systemBlue),
                        onPress: vm.flashBlue
            )
        }
    }

    private var off: some View {
        HStack {
            Spacer()
            ColorButton(symbol: .solidCircle,
                        label: "  Off  ",
                        color: Color(.systemGray3),
                        fontColor: Color.primary,
                        onPress: vm.turnOffLEDs
            )
            Spacer()
        }
    }
}

private struct ColorButton: View {

    var symbol: SFSymbol
    var label: String
    var color: Color
    var fontColor: Color = Color(.systemBackground)
    var onPress: () -> Void

    var isConstrained: Bool { ![.mac, .pad].contains(UIDevice.current.userInterfaceIdiom) }

    var body: some View {
        Button { onPress() } label: {
            ZStack {
            if isConstrained {
                Text(label)
                    .fontWeight(.semibold)
                    .font(.footnote)
                    .foregroundColor(fontColor)
            } else {
                Label(label, systemImage: symbol.rawValue)
                    .foregroundColor(fontColor)
                    .font(.callout)
            }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().foregroundColor(color))
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}
