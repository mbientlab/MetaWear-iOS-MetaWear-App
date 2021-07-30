//
//  DeviceTableViewCellVM.swift
//  DeviceTableViewCellVM
//
//  Created by Ryan on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

public class DeviceTableViewCellVM {

    weak var cell: DeviceCellDelegate? = nil

    var model: ScannerModelItem! {
        didSet {
            model.stateDidChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update(from: self!.model.device)
                }
            }
        }
    }
    var device: MetaWear? {
        didSet {
            if let device = device {
                DispatchQueue.main.async { [weak self] in
                    self?.update(from: device)
                }
            }
        }
    }

    public private(set) var uuid:         String     = uuidDefaultString
    public private(set) var rssi:         String     = "—"
    public private(set) var isConnected:  Bool       = false
    public private(set) var name:         String     = "Not Connected"
    public private(set) var signalImage:  String     = ""

    private static let uuidDefaultString: String     = "Connect for MAC"

    public func update(from device: MetaWear) {
        setSignalImage(for: device.averageRSSI())
        rssi = String(device.rssi)
        name = device.name
        uuid = device.mac ?? Self.uuidDefaultString
        isConnected = device.peripheral.state == .connected
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

public enum Images {
    case noBars
    case oneBar
    case twoBars
    case threeBars
    case fourBars
    case fiveBars
    case noSignal

    public var catalogName: String {
        switch self {
            case .noBars:    return "wifi_d1"
            case .oneBar:    return "wifi_d2"
            case .twoBars:   return "wifi_d3"
            case .threeBars: return "wifi_d4"
            case .fourBars:  return "wifi_d5"
            case .fiveBars:  return "wifi_d6"
            case .noSignal:  return "wifi_not_connected"
        }
    }
}

protocol DeviceCellDelegate: AnyObject {
    func updateView()
}
