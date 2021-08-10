//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

class ScannedDeviceCellSUIVC: MWScannedDeviceCellVM, ObservableObject, Identifiable {

    var signalActiveDots: [UUID] {
        var dots = [UUID]()
        let dotCount = min(signal.dots, SignalLevel.maxBars)
        for _ in 0..<dotCount {
            dots.append(UUID())
        }
        return dots
    }

    var signalInactiveDots: [UUID] {
        var dots = [UUID]()
        let dotCount = max(0, SignalLevel.maxBars - signal.dots)
        for _ in 0..<dotCount {
            dots.append(UUID())
        }
        return dots
    }

    init(device: MetaWear?, parent: DevicesScanningVM?) {
        super.init()
        self.parent = parent
        configure(self, for: device)
    }

    init(scannerItem: ScannerModelItem?, parent: DevicesScanningVM?) {
        super.init()
        self.parent = parent
        configure(self, for: scannerItem)
    }
}

extension ScannedDeviceCellSUIVC: ScannedDeviceCell {

    func refreshView() {
        self.objectWillChange.send()
    }
}
