//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWSignalSVC: MWDetailSignalStrengthVM, ObservableObject, DetailSignalStrengthVMDelegate {

    override init() {
        super.init()
        self.delegate = self
    }

    var indexedTransmissionLevels: [(index: Int, value: Int)] {
        self.transmissionPowerLevels.enumerated().map { ($0.offset, $0.element)
        }
    }

    func refreshView() {
        self.objectWillChange.send()
    }
}
