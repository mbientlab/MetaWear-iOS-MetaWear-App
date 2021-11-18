//
//  MWScannedDeviceCellVM.swift
//  MWScannedDeviceCellVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import Combine

public class MWScannedDeviceCellVM: ScannedDeviceCellVM {

    public weak var parent: DevicesScanningVM? = nil
    public weak var cell: ScannedDeviceCell? = nil
    private weak var model: ScannerModelItem?
    private weak var device: MetaWear?

    public private(set) var uuid:         String      = uuidDefaultString
    public private(set) var rssi:         String      = " "
    public private(set) var showRSSI:     Bool        = false
    public private(set) var isConnected:  Bool        = false
    public private(set) var name:         String      = "Not Connected"
    public private(set) var signal:       SignalLevel = .noBars
    public static let uuidDefaultString: String      = "Connect for MAC"

    public var signalImage: String { signal.imageAsset.catalogName }
    private var metawearUpdateTimer: AnyCancellable? = nil
}

public extension MWScannedDeviceCellVM {

    func configure(_ cell: ScannedDeviceCell, for device: MetaWear?) {
        self.cell = cell
        self.device = device
        self.update(from: device)
        metawearUpdateTimer = Timer
            .publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak device] _ in
                self?.update(from: device)
            }
    }

    func configure(_ cell: ScannedDeviceCell, for scannerItem: ScannerModelItem?) {
        self.cell = cell
        if let scannerItem = scannerItem {
            model = scannerItem
            model!.stateDidChange = { [weak self] in
                self?.update(from: self?.model?.device)
            }
        }
    }

    /// Prepare cell for reuse
    func cancelSubscriptions() {
        model?.stateDidChange = nil
        model = nil
        device = nil
    }

    func manuallyRefresh() {
        update(from: device)

    }
}

private extension MWScannedDeviceCellVM {

    func update(from device: MetaWear?) {
        guard let device = device else { return }

        // Use average RSSI to smooth out variability in text updates
        let rssi = Int(device.averageRSSI() ?? Double(device.rssi))
        self.rssi = String(rssi)
        self.showRSSI = rssi != 0

        if rssi == 0 {
            device.apiAccessQueue.async { [weak device] in
                device?.peripheral.readRSSI()
            }
        }

        // Use immediate RSSI for "signal dot" updates because
        // the dot categories already mask variability
        self.signal = .init(rssi: device.rssi)

        name = device.name
        uuid = device.mac ?? Self.uuidDefaultString
        isConnected = device.peripheral.state == .connected

        DispatchQueue.main.async { [weak self] in
            self?.cell?.refreshView()
            if device.peripheral.state == .connected { self?.parent?.childDeviceDidConnect() }
        }
    }
}
