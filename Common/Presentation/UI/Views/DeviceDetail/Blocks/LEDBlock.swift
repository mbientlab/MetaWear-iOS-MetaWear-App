//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct LEDBlock: View {

    @ObservedObject var vm: LedSUIVC

    var body: some View {
        PlatformSpecificThreeColumnNoOptionsLayout(
            leftColumn:  LabeledItem(label: "Steady", content: steady),
            middleColumn: LabeledItem(label: "Flash", content: flash),
            rightColumn: off
        )
    }

    var offButton: some View {
        #if os(macOS)
        off
        #else
        LabeledItem(label: "", content: off)
        #endif
    }

    private var steady: some View {
        HStack {
            ColorButton(symbol: .solidCircle,
                        label: "Red",
                        color: .ledRed,
                        onPress: vm.turnOnRed
            )

            Spacer()

            ColorButton(symbol: .solidCircle,
                        label: "Green",
                        color: .ledGreen,
                        onPress: vm.turnOnGreen
            )

            Spacer()

            ColorButton(symbol: .solidCircle,
                        label: "Blue",
                        color: .ledBlue,
                        onPress: vm.turnOnBlue
            )
        }
    }

    private var flash: some View {
        HStack {
            ColorButton(symbol: .flash,
                        label: "Red",
                        color: .ledRed,
                        onPress: vm.flashRed
            )

            Spacer()

            ColorButton(symbol: .flash,
                        label: "Green",
                        color: .ledGreen,
                        onPress: vm.flashGreen
            )

            Spacer()

            ColorButton(symbol: .flash,
                        label: "Blue",
                        color: .ledBlue,
                        onPress: vm.flashBlue
            )
        }
    }

    private var off: some View {
        HStack {
            #if !os(macOS)
            Spacer()
            #endif
            ColorButton(symbol: .solidCircle,
                        label: "  Off  ",
                        color: .ledOffPlatter,
                        fontColor: Color.primary,
                        onPress: vm.turnOffLEDs
            )
            #if !os(macOS)
            Spacer()
            #endif
        }
    }
}

private struct ColorButton: View {

    var symbol: SFSymbol
    var label: String
    var color: Color
    var fontColor: Color = .reversedTextColor
    var onPress: () -> Void

    var body: some View {
        Button { onPress() } label: {
            Text(label)
                .fontSmall(weight: .semibold)
                .foregroundColor(fontColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().foregroundColor(color))
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}
