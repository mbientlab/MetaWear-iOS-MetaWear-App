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
        switch group {

            case .headerInfoAndState: Header()

            case .identifiers:
                block(IdentifiersBlock(
                    vm: vc.vms.identifiers as! IdentifiersSUIVC,
                    firmware: vc.vms.firmware as! FirmwareSUIVC,
                    battery: vc.vms.battery as! BatterySUIVC
                ))

            case .signal:
                block(SignalBlock(vm: vc.vms.signal as! SignalSUIVC))

            case .reset:
                smallBlock(ResetBlock(vm: vc.vms.reset as! ResetSUIVC))

            case .mechanicalSwitch:
                block(MechanicalSwitchBlock(vm: vc.vms.mechanical as! MechanicalSwitchSUIVC))

            case .LED:
                block(LEDBlock(vm: vc.vms.led as! LedSUIVC))

            case .temperature:
                block(TemperatureBlock(vm: vc.vms.temperature as! TemperatureSUIVC))

            case .accelerometer:
                block(AccelerometerBlock(vm: vc.vms.accelerometer as! AccelerometerSUIVC))

            case .sensorFusion:
                block(SensorFusionBlock(vm: vc.vms.sensorFusion as! SensorFusionSUIVC))

            case .gyroscope:
                block(GyroscopeBlock(vm: vc.vms.gyroscope as! GyroSUIVC))

            case .magnetometer:
                block(MagnetometerBlock(vm: vc.vms.magnetometer as! MagnetometerSUIVC))

            case .gpio:
                block(GPIOBlock(vm: vc.vms.gpio as! GPIOSUIVC))

            case .haptic:
                block(HapticBlock(vm: vc.vms.haptic as! HapticSUIVC))

            case .ibeacon:
                block(iBeaconBlock(vm: vc.vms.ibeacon as! iBeaconSUIVC))

            case .barometer:
                block(BarometerBlock(vm: vc.vms.barometer as! BarometerSUIVC))

            case .ambientLight:
                block(AmbientLightBlock(vm: vc.vms.ambientLight as! AmbientLightSUIVC))

            case .hygrometer:
                block(HygrometerBlock(vm: vc.vms.hygrometer as! HumiditySUIVC))

            case .i2c:
                block(I2CBlock(vm: vc.vms.i2c as! I2CBusSUIVC))

        }
    }

    func block<Content: View>(_ content: Content) -> some View {
        var width: CGFloat {
#if os(macOS)
            .detailBlockWidth * 2 + .detailBlockColumnSpacing
#else
            .detailBlockWidth
#endif
        }

        return DetailsBlockCard(group: group,
                                content: content,
                                namespace: namespace,
                                width: width)
            .id(group)
    }

    func smallBlock<Content: View>(_ content: Content) -> some View {
        DetailsBlockCard(group: group,
                         content: content,
                         namespace: namespace,
                         width: .detailBlockWidth,
                         showTitle: false
        )
            .id(group)
    }
}
