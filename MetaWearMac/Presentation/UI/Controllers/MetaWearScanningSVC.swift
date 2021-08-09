//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

public class MetaWearScanningSVC: MWDevicesScanningVM, ObservableObject {

    public override init() {
        super.init()
        self.delegate = self
    }

    public var connectedDevicesIndexed: [(i: Int, device: MetaWear)] {
        zip(connectedDevices, connectedDevices.indices).map { ($0.1, $0.0 )}
    }
    public var discoveredDeviceIndexed: [(i: Int, device: ScannerModelItem)] {
        zip(discoveredDevices, discoveredDevices.indices).map { ($0.1, $0.0 )}
    }

}

extension MetaWearScanningSVC: DevicesScanningCoordinatorDelegate {

    public func refreshScanCount() {
        objectWillChange.send()
    }

    public func refreshScanningStatus() {
        objectWillChange.send()
    }

    public func refreshMetaBootStatus() {
        objectWillChange.send()
    }

    public func refreshConnectedDevices() {
        objectWillChange.send()
    }

    public func didAddDiscoveredDevice(at index: Int) {
        objectWillChange.send()
    }
}
