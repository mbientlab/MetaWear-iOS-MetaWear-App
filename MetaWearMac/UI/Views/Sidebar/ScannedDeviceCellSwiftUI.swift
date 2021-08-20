//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ScannedDeviceCellSwiftUI: View {

    @Environment(\.controlActiveState) var isActiveWindow
    @Environment(\.hasUserFocus) var hasUserFocus

    @StateObject var vc: ScannedDeviceCellSUIVC

    var body: some View {
        HStack {
            identifier
                .frame(maxWidth: .infinity, alignment: .leading)

            signal
        }
        .padding(.horizontal, 6)
        .padding(.vertical, .standardVStackSpacing)
        .onDisappear { vc.cancelSubscriptions() }
        .animation(.easeInOut, value: vc.isConnected)
    }

    private var identifier: some View {
        VStack(alignment: .leading, spacing: .standardVStackSpacing) {

            HStack {
                if vc.isConnected {
                    Image(systemName: SFSymbol.connected.rawValue)
                        .foregroundColor(hasUserFocus ? .primary : Color.accentColor)
                }

                Text(vc.name)
            }


            Text(vc.uuid)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(vc.uuid == ScannedDeviceCellSUIVC.uuidDefaultString ? .secondary : nil)
        }
    }

    private var signal: some View {
        VStack(alignment: .trailing) {

            SignalDots(vc: vc, color: hasUserFocus ? .primary : nil)

        }
        .help("\(vc.rssi) RSSI (Received Signal Strength)")

    }
}
