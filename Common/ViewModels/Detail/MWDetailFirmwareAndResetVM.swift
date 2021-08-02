//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailFirmwareAndResetVM: DetailIdentifiersVM {

    public var firmwareUpdateStatus = ""

    public var delegate: DetailFirmwareAndResetVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailFirmwareAndResetVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailFirmwareAndResetVM {

    public func start() {
        updateState()
    }

    private func updateState() {
        guard let device = device else { return }

        device.checkForFirmwareUpdate().continueWith(.mainThread) {
            if let result = $0.result {
                self.firmwareUpdateStatus = result != nil ? "\(result!.firmwareRev) AVAILABLE!" : "Up To Date"
            } else {
                self.firmwareUpdateStatus = "Unknown"
            }
        }

        delegate?.refreshView()
    }
}
