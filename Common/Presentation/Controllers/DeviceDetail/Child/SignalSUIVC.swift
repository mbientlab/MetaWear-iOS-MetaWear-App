//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class SignalSUIVC: MWSignalVM, ObservableObject, SignalVMDelegate {

    public var indexedTransmissionLevels: [(index: Int, value: Int)] {
        self.transmissionPowerLevels.enumerated().map { ($0.offset, $0.element)
        }
    }

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}
