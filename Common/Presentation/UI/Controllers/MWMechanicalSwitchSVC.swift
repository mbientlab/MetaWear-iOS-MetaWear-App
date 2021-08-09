//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MWMechanicalSwitchSVC: MWDetailMechanicalSwitchVM, DetailMechanicalSwitchVMDelegate, ObservableObject {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}
