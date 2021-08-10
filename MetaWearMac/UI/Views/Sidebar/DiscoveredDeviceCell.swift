//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI


struct DiscoveredDeviceCell: View {

    var device: DeviceItem

    var body: some View {
        HStack {
            identifier
                .frame(maxWidth: .infinity, alignment: .leading)

            signal
        }
    }

    private var identifier: some View {
        VStack {
            Text(device.name)
            Text(device.mac)
        }
    }

    private var signal: some View {
        VStack(alignment: .trailing) {
            Text(device.signal)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)

            Spacer()
            
            SignalDots(dots: device.signalLevel)
        }
    }
}
