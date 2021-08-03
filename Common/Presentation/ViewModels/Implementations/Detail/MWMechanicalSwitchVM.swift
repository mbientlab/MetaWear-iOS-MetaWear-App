//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailMechanicalSwitchVM: DetailMechanicalSwitchVM {

    public var isMonitoring = false
    public var switchState = ""

    public var delegate: DetailMechanicalSwitchVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailMechanicalSwitchVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailMechanicalSwitchVM {

    public func start() {
        // Do nothing
    }
}


// MARK: - Intents


extension MWDetailMechanicalSwitchVM {

    public func userStartedMonitoringSwitch() {

        guard !isMonitoring, let device = device else { return }
        isMonitoring = true

        let signal = mbl_mw_switch_get_state_data_signal(device.board)!

        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let switchVal: UInt32 = obj!.pointee.valueAs()
            let _self: MWDetailMechanicalSwitchVM = bridge(ptr: context!)
            
            DispatchQueue.main.async {
                _self.switchState = (switchVal != 0) ? "Down" : "Up (0)"
                _self.delegate?.refreshView()
            }
        }

        parent?.storeStream(signal, cleanup: nil)

        delegate?.refreshView()
    }

    public func userStoppedMonitoringSwitch() {
        isMonitoring = false
        guard let device = device else { return }

        let signal = mbl_mw_switch_get_state_data_signal(device.board)!
        parent?.removeStream(signal)

        delegate?.refreshView()
    }

}
