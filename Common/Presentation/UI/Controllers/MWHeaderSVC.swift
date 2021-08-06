//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWDetailHeaderSVC: MWDetailHeaderVM, ObservableObject {

    override init() {
        super.init()
        self.delegate = self
    }
}

extension MWDetailHeaderSVC: DetailHeaderVMDelegate {

    func refreshView() {
        self.objectWillChange.send()
    }
}
