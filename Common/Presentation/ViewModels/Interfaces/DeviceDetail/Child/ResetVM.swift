//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol ResetVM: AnyObject, DetailConfiguring {

    var delegate: ResetVMDelegate? { get set }

    // Intents
    func userRequestedSoftReset()
    func userRequestedFactoryReset()
    func userRequestedSleep()
}

public protocol ResetVMDelegate: AnyObject {
    func refreshView()
}
