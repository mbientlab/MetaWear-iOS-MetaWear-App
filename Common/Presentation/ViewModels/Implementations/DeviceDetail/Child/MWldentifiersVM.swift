//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWIdentifiersVM: IdentifiersVM {

    public private(set) var manufacturer = " "
    public private(set) var modelNumber = " "
    public private(set) var serialNumber = " "
    public private(set) var harwareRevision = " "
    public private(set) var model: MetaWearDeviceModel = .notFound

    // Identity
    public weak var delegate: IdentifiersVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil
}

extension MWIdentifiersVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        updateIdentifiers()
    }

}

private extension MWIdentifiersVM {

     func updateIdentifiers() {
        guard let device = device else { return }
        let na = "N/A"

        manufacturer = device.info?.manufacturer ?? na
        serialNumber = device.info?.serialNumber ?? na
        harwareRevision = device.info?.hardwareRevision ?? na
        modelNumber = "\(device.info?.modelNumber ?? na) (\(String(cString: mbl_mw_metawearboard_get_model_name(device.board))))"
        model = .init(device: device)
        delegate?.refreshView()
    }
}
