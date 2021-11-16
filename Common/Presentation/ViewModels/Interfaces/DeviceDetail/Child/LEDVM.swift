//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol LedVM: AnyObject, DetailConfiguring {

    var delegate: LedVMDelegate? { get set }

    func turnOnGreen()
    func flashGreen()
    func turnOnRed()
    func flashRed()
    func turnOnBlue()
    func flashBlue()

    func turnOffLEDs()
}

public protocol LedVMDelegate: AnyObject {
    func refreshView()
}
