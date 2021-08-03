//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol DetailResetVM: AnyObject, DetailConfiguring {

    var delegate: DetailResetVMDelegate? { get set }

    func start()

    // Intents
    func userRequestedSoftReset()
    func userRequestedFactoryReset()
    func userRequestedSleep()
}

public protocol DetailResetVMDelegate: AnyObject {
    func refreshView()
}
