//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

/// Until a Swift Evolution proposal passes, SwiftUI doesn't completely play well with protocol composition (generics get out of hand when passing a container of injected VMs/VCs). Here, views force cast a  declarative VM wrapper.
///
struct BlockBuilder: View  {

    var group: DetailGroup
    var namespace: Namespace.ID
    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC

    var body: some View {
        DetailsBlockCard(group: group, content: content, namespace: namespace)
    }

    @ViewBuilder var content: some View {
        switch group {

            case .identifiers:
                IdentifiersBlock(vm: vc.vms.identifiers as! IdentifiersSUIVC)

            case .battery:
                BatteryBlock(vm: vc.vms.battery as! BatterySUIVC)

            case .signal:
                SignalBlock(vm: vc.vms.signal as! SignalSUIVC)

            case .firmware:
                FirmwareBlock(vm: vc.vms.firmware as! FirmwareSUIVC)

            case .reset:
                ResetBlock(vm: vc.vms.reset as! ResetSUIVC)

            case .mechanicalSwitch:
                MechanicalSwitchBlock(vm: vc.vms.mechanical as! MechanicalSwitchSUIVC)

            case .LED:
                LEDBlock(vm: vc.vms.led as! LedSUIVC)

            case .temperature:
                TemperatureBlock(vm: vc.vms.temperature as! TemperatureSUIVC)

            case .accelerometer:
                AccelerometerBlock(vm: vc.vms.accelerometer as! AccelerometerSUIVC)

                // MARK: - Not Yet Built

            case .sensorFusion:
                SensorFusionBlock()

            case .gyroscope:
                GyroscopeBlock(vm: MWGyroVM())

            case .magnetometer:
                MagnetometerBlock() //

            case .gpio:
                GPIOBlock() // 

            case .haptic:
                HapticBlock() // 

            case .ibeacon:
                iBeaconBlock() //

            case .barometer:
                BarometerBlock(vm: vc.vms.barometer as! BarometerSUIVC)

            case .ambientLight:
                AmbientLightBlock(vm: vc.vms.ambientLight as! AmbientLightSUIVC)

            case .hygrometer:
                HygrometerBlock() //

            case .i2c:
                I2CBlock(vm: vc.vms.i2c as! I2CBusSUIVC)

            case .headerInfoAndState:
                HeaderBlock(vm: vc.vms.header as! DetailHeaderSUIVC)

        }
    }
}
