//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import iOSDFULibrary

public class MWDetailFirmwareVM: DetailFirmwareVM {

    public var firmwareUpdateStatus = ""
    public var firmwareRevision = ""

    public var delegate: DetailFirmwareAndResetVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailFirmwareVM: DFUProgressDelegate {

    public func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        parent?.hud.updateProgressHUD(percentage: Float(progress) / 100)
    }

}

extension MWDetailFirmwareVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailFirmwareVM {

    public func start() {
        setFirmwareRevision()
        userRequestedCheckForFirmwareUpdates()
    }

    private func setFirmwareRevision() {
        guard let device = device else { return }
        let na = "N/A"
        firmwareRevision = device.info?.firmwareRevision ?? na
    }
}

// MARK: - Intent

extension MWDetailFirmwareVM {

    public func userRequestedCheckForFirmwareUpdates() {
        guard let device = device else { return }
        device.checkForFirmwareUpdate().continueWith(.mainThread) {
            if let error = $0.error {
                self.delegate?.presentAlert(title: "Firmware Error", message: error.localizedDescription)
            } else {
                self.firmwareUpdateStatus = $0.result! != nil ? "\($0.result!!.firmwareRev) AVAILABLE!" : "Up To Date"
            }
            self.delegate?.refreshView()
        }
    }

    public func userRequestedUpdateFirmware() {
        guard let device = device else { return }

        // Pause the screen while update is going on
        parent?.hud.presentProgressHUD(label: "Updating...", in: nil)

        device.updateFirmware(delegate: self).continueWith { t in
            if let error = t.error {
                DispatchQueue.main.async {
                    self.delegate?.presentAlert(
                        title: "Firmware Update Error",
                        message: "Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: \(error.localizedDescription)"
                    )

                    self.parent?.hud.closeHUD(finalMessage: "", delay: 0)
                }
            } else {
                DispatchQueue.main.async {
                    self.parent?.hud.closeHUD(finalMessage: "Success")
                }
            }
        }
    }
}
