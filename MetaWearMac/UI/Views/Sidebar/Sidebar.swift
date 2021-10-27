//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct Sidebar: View {

    @StateObject var vc: MetaWearScanningSVC
    @Namespace private var chain
    @State private var selection: String? = nil

    var body: some View {
        List {
            ScanButton()
            MetaBootCheckButton()

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
                }
            }
            .controlSize(.small)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Discovered Devices")
            .animation(.easeOut(duration: 0.25), value: vc.discoveredDeviceIndexed.endIndex)

            TapToConnectPrompt(didNavigate: selection != nil)
        }
        .environmentObject(vc)
        .onAppear { vc.startScanning() }
        .accessibilityLabel("Sidebar")
        .toolbar { SidebarToggle() }
    }

    var discoveredHeader: some View {
        Label(" Discovered", systemImage: SFSymbol.search.rawValue).fontSmall()
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("Discovered Devices")
    }
}
