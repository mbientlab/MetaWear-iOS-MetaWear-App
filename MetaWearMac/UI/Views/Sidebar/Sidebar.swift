//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct Sidebar: View {

    @EnvironmentObject private var vc: MetaWearScanningSVC
    @Namespace var chain

    @State var selection: String? = nil
    var body: some View {
        List {
            ScanButton().animation(.easeOut(duration: 0.25))

            MetaBootCheckButton().animation(.easeOut(duration: 0.25))

            Section(header: connectedHeader) {
                ForEach(vc.connectedDevicesIndexed, id: \.i) { (index, _) in
                    DeviceNavigationLink(
                        chain: chain,
                        selection: $selection,
                        index: index,
                        isDiscoveredList: false
                    ).accessibilityLinkedGroup(id: "details", in: chain)
                }
            }.animation(.easeOut(duration: 0.25))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Connected Devices")

            Section(header: discoveredHeader) {
                ForEach(vc.discoveredDeviceIndexed, id: \.i) { (index, _) in
                    DeviceNavigationLink(
                        chain: chain,
                        selection: $selection,
                        index: index,
                        isDiscoveredList: true
                    ).accessibilityLinkedGroup(id: "details", in: chain)

                    if vc.discoveredDevices.isEmpty {
                        EmptyDevicesListButton()
                    }
                }.animation(.easeOut(duration: 0.25))

            }
            .controlSize(.small)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Discovered Devices")

            TapToConnectPrompt(didNavigate: selection != nil)
        }
        .accessibilityLabel("Sidebar")
        .toolbar { SidebarToggle() }
    }

    var connectedHeader: some View {
        Label(" Connected", systemImage: SFSymbol.connected.rawValue).fontSmall()
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("Connected Devices")
    }

    var discoveredHeader: some View {
        Label(" Discovered", systemImage: SFSymbol.search.rawValue).fontSmall()
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("Discovered Devices")
    }
}
