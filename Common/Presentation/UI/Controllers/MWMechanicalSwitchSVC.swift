//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWMechanicalSwitchSVC: MWDetailMechanicalSwitchVM, DetailMechanicalSwitchVMDelegate, ObservableObject {

    func refreshView() {
        self.objectWillChange.send()
    }

    override init() {
        super.init()
        self.delegate = self
    }
}
