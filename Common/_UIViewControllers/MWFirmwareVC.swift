//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWFirmwareSVC: MWDetailFirmwareVM, ObservableObject, DetailFirmwareVMDelegate {

    override init() {
        super.init()
        self.delegate = self
    }

    func refreshView() {
        self.objectWillChange.send()
    }
}
