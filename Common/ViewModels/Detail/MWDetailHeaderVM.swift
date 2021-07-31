//
//  MWDetailHeaderVM.swift
//  MWDetailHeaderVM
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailHeaderVM {

    public weak var delegate: DetailHeaderVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

    public private(set) var deviceName: String = ""
    public private(set) var connectionState: String = ""
    public private(set) var connectionIsOn: Bool = false

}

extension MWDetailHeaderVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailHeaderVM: DetailHeaderVM {

    public func start() {
        refreshName()
        refreshConnectionState()
        delegate?.refreshView()
    }

    public func refreshName() {
        guard let device = device else { return }
        deviceName = device.name
    }

    public func refreshConnectionState() {
        guard let device = device else { return }

        connectionIsOn = device.peripheral.state == .connected

        switch device.peripheral.state {
            case .connected:        deviceName = "Connected"
            case .connecting:       deviceName = "Connecting"
            case .disconnected:     deviceName = "Disconnected"
            case .disconnecting:    deviceName = "Disconnecting"
            @unknown default:       deviceName = "Unknown API Value"
        }
    }
}

extension MWDetailHeaderVM {

    public func userSetConnection(to newState: Bool) {
        parent?.connectDevice(newState)
    }

    public func userUpdatedName(to newValue: String) {
        guard let device = device else { return }
        let ud = UserDefaults.standard
        let key = UserDefaults.deviceNameKey

        if ud.object(forKey: key) == nil {
            ud.set(1, forKey: key)
            ud.synchronize()
            presentAlert(
                in: UIApplication.shared.windows.first(where: \.isKeyWindow)!.rootViewController!,
                title: "iOS Caches Names",
                message: "To see the new name, you may need to disconnect, re-connect several times or force close the app."
            )
        }

        mbl_mw_settings_set_device_name(device.board, newValue, UInt8(newValue.count))
    }
}

// MARK: - Intents

extension MWDetailHeaderVM {

    public func didUserTypeValidDeviceName(_ newString: String, range: NSRange, fullString: String) -> Bool {
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

