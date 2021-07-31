//
//  MWScannedDeviceCellVM.swift
//  MWScannedDeviceCellVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

public class MWScannedDeviceCellVM: ScannedDeviceCellVM {

    public weak var cell: ScannedDeviceCell? = nil
    private weak var model: ScannerModelItem?
    private weak var device: MetaWear?

    public private(set) var uuid:         String     = uuidDefaultString
    public private(set) var rssi:         String     = "—"
    public private(set) var isConnected:  Bool       = false
    public private(set) var name:         String     = "Not Connected"
    public private(set) var signalImage:  String     = ""

    private static let uuidDefaultString: String     = "Connect for MAC"

}

public extension MWScannedDeviceCellVM {

    func configure(_ cell: ScannedDeviceCell, for device: MetaWear?) {
        self.cell = cell
        self.device = device
        self.update(from: device)
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
}

private extension MWScannedDeviceCellVM {

    private func update(from device: MetaWear?) {
        guard let device = device else { return }

        setSignalImage(for: device.averageRSSI())
        rssi = String(device.rssi)
        name = device.name
        uuid = device.mac ?? Self.uuidDefaultString
        isConnected = device.peripheral.state == .connected

        DispatchQueue.main.async { [weak self] in
            self?.cell?.refreshView()
        }
    }

    private func setSignalImage(for averageRSSI: Double?) {

        var asset = Images.noBars
        defer { signalImage = asset.catalogName }

        guard let rssi = averageRSSI else { return }

        switch rssi {
            case ...(-80): asset = .noBars
            case ...(-70): asset = .oneBar
            case ...(-60): asset = .twoBars
            case ...(-50): asset = .threeBars
            case ...(-40): asset = .fourBars
            default:       asset = .fiveBars
        }
    }
}
