//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ConnectionToolbarButton: View {

    @ObservedObject var vm: DetailHeaderSUIVC

    var body: some View {
        Button { vm.userSetConnection(to: !vm.connectionIsOn) } label: {
#if os(iOS)
            iOSLabel
#else
            macOSLabel
                .help(macCommandLabel)
                .accessibilityHidden(true)
#endif

        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(macCommandLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Your MetaWear is currently \(vm.connectionState)")
        .animation(.easeInOut, value: vm.didConnectOnce)
    }

    @ViewBuilder var macOSLabel: some View {
        Text(macCommandLabel)
            .foregroundColor(vm.connectionIsOn ? .mwSecondary : .primary)
            .opacity(vm.didConnectOnce ? 1 : 0)

        Image(systemName: vm.connectionIsOn ? SFSymbol.connected.rawValue : SFSymbol.disconnected.rawValue)
            .foregroundColor(vm.connectionIsOn ? .accentColor : Color(.systemPink))
    }

    var iOSLabel: some View {
        Image(systemName: vm.connectionIsOn ? SFSymbol.connected.rawValue : SFSymbol.disconnected.rawValue)
            .foregroundColor(vm.connectionIsOn ? .accentColor : Color(.systemPink))
            .colorMultiply(vm.connectionIsOn ? .accentColor : Color(.systemPink))
            .accentColor(vm.connectionIsOn ? .accentColor : Color(.systemPink))
    }

    private var isConnected: Binding<Bool> {
        Binding { vm.connectionIsOn }
        set: { vm.userSetConnection(to: $0) }
    }

    var macCommandLabel: String {
        vm.connectionIsOn ? "Disconnect" : "Reconnect"
    }
}
