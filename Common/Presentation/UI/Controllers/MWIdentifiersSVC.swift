//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWDetailIdentifiersSVC: MWDetailIdentifiersVM, ObservableObject, DetailIdentifiersVMDelegate {

    func refreshView() {
        self.objectWillChange.send()
    }

    override init() {
        super.init()
        self.delegate = self
    }
}

