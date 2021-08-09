//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MWDetailIdentifiersSVC: MWDetailIdentifiersVM, ObservableObject, DetailIdentifiersVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

