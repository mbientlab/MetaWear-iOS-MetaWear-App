//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWMechanicalSwitchVM: MechanicalSwitchVM {

    public private(set) var isMonitoring = false
    public private(set) var switchState = ""

    // Identity
    public var delegate: MechanicalSwitchVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWMechanicalSwitchVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        // Do nothing
    }
}

// MARK: - Intents

public extension MWMechanicalSwitchVM {

    func userStartedMonitoringSwitch() {
        guard !isMonitoring, let device = device else { return }
        isMonitoring = true
        delegate?.refreshView()

        let signal = mbl_mw_switch_get_state_data_signal(device.board)!

        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let switchVal: UInt32 = obj!.pointee.valueAs()
            let _self: MWMechanicalSwitchVM = bridge(ptr: context!)
            
            DispatchQueue.main.async {
                _self.setSwitchState(switchVal)
                _self.delegate?.refreshView()
            }
        }

        parent?.storeStream(signal, cleanup: nil)
    }

    func userStoppedMonitoringSwitch() {
        isMonitoring = false
        delegate?.refreshView()
        stopReadingSignal()
    }

}

// MARK: - Helpers

private extension MWMechanicalSwitchVM {

    func setSwitchState(_ value: UInt32) {
        switchState = (value != 0) ? "Down" : "Up (0)"
    }

    func stopReadingSignal() {
        guard let device = device else { return }
        let signal = mbl_mw_switch_get_state_data_signal(device.board)!
        parent?.removeStream(signal)
    }
}
