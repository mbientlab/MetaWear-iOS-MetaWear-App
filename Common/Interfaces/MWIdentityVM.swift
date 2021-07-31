//
//  MWIdentityVM.swift
//  MetaWearApp
//
//  Created by Ryan on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import BoltsSwift
import iOSDFULibrary

class MWIdentityVM {


}

class MWDeviceDetailsController: NSObject {

    var device: MetaWear!
    var initiator: DFUServiceInitiator?
    var dfuController: DFUServiceController?

    var bmi270: Bool = false

    var streamingEvents: Set<OpaquePointer> = []
    var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    var loggers: [String: OpaquePointer] = [:]

    var disconnectTask: Task<MetaWear>?
    var isObserving = false {
        didSet {
            if self.isObserving {
                if !oldValue {
                    self.device.peripheral.addObserver(self, forKeyPath: "state", options: .new, context: nil)
                }
            } else {
                if oldValue {
                    self.device.peripheral.removeObserver(self, forKeyPath: "state")
                }
            }
        }
    }

    var accelerometerBMI160StepCount = 0
    var accelerometerBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    var gyroBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    var magnetometerBMM150Data: [(Int64, MblMwCartesianFloat)] = []
    var gpioPinChangeCount = 0
    var hygrometerBME280Event: OpaquePointer?
    var sensorFusionData = Data()

}
