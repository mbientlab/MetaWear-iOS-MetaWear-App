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
        if isValid {
            navigationLink

                .accessibilityElement(children: .ignore)
                .accessibilityLabel(getName())
                .accessibilityHint(getSignalStrength())
                .accessibilityAddTraits(selection == makeTag() ? [.isButton, .isSelected] : .isButton)
                .accessibilityAction(named: "Connect") { selection = makeTag() }
                // Context menus must be placed outside the NavLink in SwiftUI 3-
                .contextMenu {
                    CopyButton(string: getDevice()?.mac ?? "Unavailable", label: "Copy MAC")
                }
        }
    }

    var navigationLink: some View {
        #if swift(>=5.5)
        NavigationLink(tag: makeTag(), selection: $selection) { destination } label: { label }
        #else
        NavigationLink(
            destination: destination,
            tag: makeTag(),
            selection: $selection,
            label: { label }
        )
        #endif
    }

    var label: some View {
        ScannedDeviceCellSwiftUI(vc: makeCellVC())
            .fontBody()
            .environment(\.hasUserFocus, selection == makeTag())
    }

    var destination: some View {
        DeviceDetailScreenMacContainer(vc: getDetailSVC(), chain: chain)
    }

    func makeTag() -> String {
        isDiscoveredList ? "discovered\(index)" : "connected\(index)"
    }
}

// MARK: - Temporary View Model

private extension DeviceNavigationLink {

    // Segue

    func getDevice() -> MetaWear? {
        isDiscoveredList
            ? vc.discoveredDevices[index].device
            : vc.connectedDevices[index]
    }

    func getDetailSVC() -> DeviceDetailScreenSUIVC {
        app.ui.makeDetailScreenVC(device: getDevice()) as! DeviceDetailScreenSUIVC
    }
    
    // Accessibility

    var isValid: Bool {
        isDiscoveredList
            ? vc.discoveredDevices.indices.contains(index)
            : vc.connectedDevices.indices.contains(index)
    }
    
    func getName() -> String {
        if isDiscoveredList {
            return vc.discoveredDevices.indices.contains(index) ? vc.discoveredDevices[index].device.name : ""
        } else {
            return vc.connectedDevices.indices.contains(index) ? vc.connectedDevices[index].name : ""
        }
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

}
