//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import iOSDFULibrary

public class MWDetailFirmwareVM: FirmwareVM {

    public private(set) var firmwareUpdateStatus = " "
    public private(set) var firmwareRevision = " "
    public private(set) var offerUpdate = false

    // Identity
    public weak var delegate: FirmwareVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailFirmwareVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        refreshFirmwareVersionUIState()
        delegate?.refreshView()
        userRequestedCheckForFirmwareUpdates()
    }
}

extension MWDetailFirmwareVM: DFUProgressDelegate {

    public func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        parent?.toast.updateProgress(percentage: progress)
    }

}

// MARK: - Intent

public extension MWDetailFirmwareVM {

    func userRequestedCheckForFirmwareUpdates() {
        guard let device = device else { return }

        device.checkForFirmwareUpdate().continueWith(.mainThread) { [weak self] in
            if let error = $0.error {
                self?.parent?.alerts.presentAlert(title: "Firmware Error", message: error.localizedDescription)

            } else {

                let updateAvailable = $0.result! != nil
                self?.offerUpdate = updateAvailable
                self?.firmwareUpdateStatus = updateAvailable
                ? $0.result!!.firmwareRev
                : "Up To Date"
            }

            self?.refreshFirmwareVersionUIState()
            self?.delegate?.refreshView()
        }
    }

    func userRequestedUpdateFirmware() {
        guard let device = device else { return }

        // Pause the screen while update is going on
        parent?.toast.present(mode: .horizontalProgress,
                              "Updating",
                              disablesInteraction: true,
                              onDismiss: nil)

        device.updateFirmware(delegate: self).continueWith { [weak self] t in
            guard let self = self else { return }

            if let error = t.error {
                DispatchQueue.main.async { [weak self] in
                    self?.parent?.alerts.presentAlert(
                        title: "Firmware Update Error",
                        message: "Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: \(error.localizedDescription)"
                    )

                    self?.parent?.toast.dismiss(delay: 0)
                }

            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.parent?.toast.dismiss(updatingText: "Success", disablesInteraction: false, delay: .defaultToastDismissalDelay)
                    self?.refreshFirmwareVersionUIState()
                    self?.delegate?.refreshView()
                }
            }
        }
    }
}

// MARK: - Helpers

private extension MWDetailFirmwareVM {

    func refreshFirmwareVersionUIState() {
        guard let device = device else { return }
        let na = "N/A"
        firmwareRevision = device.info?.firmwareRevision ?? na
    }
}
