//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

struct DeviceNavigationLink: View {

    @EnvironmentObject private var app: AppStore
    @EnvironmentObject private var vc: MetaWearScanningSVC
    var chain: Namespace.ID
    @Binding var selection: String?
    var index: Int
    var isDiscoveredList: Bool

    var body: some View {
        NavigationLink(tag: makeTag(), selection: $selection) {
            DeviceDetailScreenMacContainer(vc: getDetailSVC(), chain: chain)
        } label: {
            ScannedDeviceCellSwiftUI(vc: makeCellVC())
                .fontBody()
                .environment(\.hasUserFocus, selection == makeTag())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(getName())
        .accessibilityHint(getSignalStrength())
        .accessibilityAddTraits(selection == makeTag() ? [.isButton, .isSelected] : .isButton)
        .accessibilityAction(named: "Connect", {
            selection = makeTag()
        })
        // Context menus must be placed outside the NavLink in SwiftUI 3-
        .contextMenu {
            CopyButton(string: getDevice()?.mac ?? "Unavailable", label: "Copy MAC")
        }
    }
}

private extension DeviceNavigationLink {

    // Accessibility

    func getName() -> String {
        isDiscoveredList
        ? vc.discoveredDevices[index].device.name
        : vc.connectedDevices[index].name
    }

    func getSignalStrength() -> String {
        "Signal Strength " + String(isDiscoveredList
                                    ? vc.discoveredDevices[index].device.rssi
                                    : vc.connectedDevices[index].rssi)
    }

    func makeCellVC() -> ScannedDeviceCellSUIVC {
        isDiscoveredList
        ? app.ui.makeScannedDeviceCellSVC(scannerItem: vc.discoveredDevices[index], parent: vc) as! ScannedDeviceCellSUIVC
        : app.ui.makeScannedDeviceCellSVC(device: vc.connectedDevices[index], parent: vc) as! ScannedDeviceCellSUIVC
    }

    // Segue

    func makeTag() -> String {
        isDiscoveredList ? "discovered\(index)" : "connected\(index)"
    }

    func getDevice() -> MetaWear? {
        isDiscoveredList
        ? vc.discoveredDevices[index].device
        : vc.connectedDevices[index]
    }

    func getDetailSVC() -> MWDeviceDetailScreenSVC {
        app.ui.makeDetailScreenVC(device: getDevice()) as! MWDeviceDetailScreenSVC
    }
}
