//
//  CardBuilder.swift
//  CardBuilder
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

/// Swift\SwiftUI requires a concrete type for ObservedObjects, which already have an associated type.
/// Protocol-oriented refactoring meant for AppKit requires, until an evolution proposal changes the above,
/// SwiftUI views depend on child of a subclass implementing the VM protocol.
/// Kinda smelly, but leaves options open.
struct CardBuilder: View  {

    var group: DetailGroup
    var namespace: Namespace.ID
    @EnvironmentObject private var vc: MWDeviceDetailScreenSVC

    var body: some View {
        DetailsBlockCard(group: group, content: content, namespace: namespace)
    }

    @ViewBuilder var content: some View {
        switch group {

            case .identifiers:
                IdentifiersBlock(vm: vc.vms.identifiers as! MWDetailIdentifiersSVC)

            case .battery:
                BatteryBlock(vm: vc.vms.battery as! MWDetailBatterySVC)

            case .signal:
                SignalBlock(vm: vc.vms.signal as! MWSignalSVC)

            case .firmware:
                FirmwareBlock(vm: vc.vms.firmware as! MWFirmwareSVC)

            case .reset:
                ResetBlock(vm: vc.vms.reset as! MWResetSVC)

            case .mechanicalSwitch:
                MechanicalSwitchBlock(vm: vc.vms.mechanical as! MWMechanicalSwitchSVC)

            case .LED:
                LEDBlock(vm: vc.vms.led as! MWLEDSVC)

            case .temperature:
                TemperatureBlock(vm: vc.vms.temperature as! MWTemperatureSVC)

            case .accelerometer:
                AccelerometerBlock(vm: vc.vms.accelerometer as! MWAccelerometerSVC)

                // MARK: - Not Yet Refactored

            case .sensorFusion:
                SensorFusionBlock()

            case .gyroscope:
                GyroscopeBlock()

            case .magnetometer:
                MagnetometerBlock()

            case .gpio:
                GPIOBlock()

            case .haptic:
                HapticBlock()

            case .ibeacon:
                iBeaconBlock()

            case .barometer:
                BarometerBlock()

            case .ambientLight:
                AmbientLightBlock()

            case .i2c:
                I2CBlock()

            case .headerInfoAndState:
                HeaderBlock(vm: vc.vms.header as! MWDetailHeaderSVC)

        }
    }
}
