//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWDetailIdentifiersSVC: MWDetailIdentifiersVM, ObservableObject, DetailIdentifiersVMDelegate {

    override init() {
        super.init()
        self.delegate = self
    }

    func refreshView() {
        self.objectWillChange.send()
    }
}

