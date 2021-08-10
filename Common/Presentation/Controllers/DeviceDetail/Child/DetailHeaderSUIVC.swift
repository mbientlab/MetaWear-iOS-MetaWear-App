//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class DetailHeaderSUIVC: MWDetailHeaderVM, ObservableObject {

    @Published var didConnectOnce = false

    public override init() {
        super.init()
        self.delegate = self
    }
}

extension DetailHeaderSUIVC: HeaderVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
        if connectionIsOn && didConnectOnce == false {
            didConnectOnce = true
        }
    }
}
