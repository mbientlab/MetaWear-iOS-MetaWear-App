//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWTemperatureSVC: MWDetailTemperatureVM, DetailTemperatureVMDelegate, ObservableObject {

    override init() {
        super.init()
        self.delegate = self
    }

    var channelsIndexed: [(index: Int, label: String)] {
        self.channels.enumerated().map { ($0.offset, $0.element)  }
    }

    func refreshView() {
        self.objectWillChange.send()
    }

    func resetView() {
        self.objectWillChange.send()
    }
}
