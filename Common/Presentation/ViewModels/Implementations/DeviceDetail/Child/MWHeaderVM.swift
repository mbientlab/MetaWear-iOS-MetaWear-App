//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailHeaderVM: HeaderVM {

    public private(set) var deviceName: String = " "
    public private(set) var connectionState: String = " "
    public private(set) var connectionIsOn: Bool = false
    public let deviceNameRequirementsMessage = "Less than 8 characters (ASCII only)"

    // Identity
    public weak var delegate: HeaderVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil
}

extension MWDetailHeaderVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        refreshConnectionState()
        refreshName()
        delegate?.refreshView()
    }
}

public extension MWDetailHeaderVM {

    func refreshName() {
        guard let device = device else { return }
        deviceName = device.name
        delegate?.refreshView()
    }

    func refreshConnectionState() {
        guard let device = device else { return }

        connectionIsOn = device.peripheral.state == .connected

        switch device.peripheral.state {
            case .connected:        connectionState = "Connected"
            case .connecting:       connectionState = "Connecting"
            case .disconnected:     connectionState = "Disconnected"
            case .disconnecting:    connectionState = "Disconnecting"
            @unknown default:       connectionState = "Unknown API Value"
        }

        delegate?.refreshView()
    }
}

// MARK: - Intents

public extension MWDetailHeaderVM {

    func userSetConnection(to shouldConnect: Bool) {
        if shouldConnect {
            parent?.connectDevice(shouldConnect)
        } else {
            parent?.userRequestedDeviceDisconnect()
        }
    }

    func userRenamedDevice(to newValue: String) {
        guard let device = device else { return }
        let ud = UserDefaults.standard
        let key = UserDefaults.deviceNameKey

        if ud.object(forKey: key) == nil {
            ud.set(1, forKey: key)
            ud.synchronize()
            parent?.alerts.presentAlert(
                title: "CoreBluetooth Caches Names",
                message: "To see the new name, you may need to disconnect, re-connect several times or force close the app."
            )
        }

        mbl_mw_settings_set_device_name(device.board, newValue, UInt8(newValue.count))
    }
}

public extension MWDetailHeaderVM {

    func didUserTypeValidDevice(name: String) -> Bool {
        guard name.count <= 8 else { return false }
        return name.data(using: String.Encoding.ascii) != nil
    }

    func didUserTypeValidDeviceName(_ newString: String, range: NSRange, fullString: String) -> Bool {
        let fullStringCount = fullString.count

        // Prevent Undo crashing bug
        if range.length + range.location > fullStringCount { return false }

        // Make sure it's no longer than 8 characters
        let newLength = fullStringCount + newString.count - range.length
        if newLength > 8 { return false }

        // Make sure we only use ASCII characters
        return newString.data(using: String.Encoding.ascii) != nil
    }

}
