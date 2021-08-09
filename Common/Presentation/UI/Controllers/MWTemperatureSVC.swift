//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MWTemperatureSVC: MWDetailTemperatureVM, DetailTemperatureVMDelegate, ObservableObject {

    public var channelsIndexed: [(index: Int, label: String)] {
        self.channels.enumerated().map { ($0.offset, $0.element)  }
    }

    public func refreshView() {
        self.objectWillChange.send()
    }

    public func resetView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}
