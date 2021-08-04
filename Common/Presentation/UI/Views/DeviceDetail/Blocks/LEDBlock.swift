//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct LEDBlock: View {

    @ObservedObject var vm: MWLEDSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "Steady",
                content: steady
            )

            LabeledItem(
                label: "Flash",
                content: flash
            )

            Button("Turn Off LED") { vm.turnOffLEDs() }
        }
    }

    var steady: some View {
        HStack {
            ColorButton(symbol: .solidCircle,
                        label: "Red",
                        color: Color(.systemRed),
                        onPress: vm.turnOnRed
            )

            ColorButton(symbol: .solidCircle,
                        label: "Green",
                        color: Color(.systemGreen),
                        onPress: vm.turnOnGreen
            )

            ColorButton(symbol: .solidCircle,
                        label: "Blue",
                        color: Color(.systemBlue),
                        onPress: vm.turnOnBlue
            )
        }
    }

    var flash: some View {
        HStack {
            ColorButton(symbol: .flash,
                        label: "Red",
                        color: Color(.systemRed),
                        onPress: vm.flashRed
            )

            ColorButton(symbol: .flash,
                        label: "Green",
                        color: Color(.systemGreen),
                        onPress: vm.flashGreen
            )

            ColorButton(symbol: .flash,
                        label: "Blue",
                        color: Color(.systemBlue),
                        onPress: vm.flashBlue
            )
        }
    }

}

private struct ColorButton: View {

    var symbol: SFSymbol
    var label: String
    var color: Color
    var onPress: () -> Void

    var body: some View {
        Button { onPress() } label: {
            Label(label, systemImage: symbol.rawValue)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}
