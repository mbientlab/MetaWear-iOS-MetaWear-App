//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//


import Foundation

public protocol DetailLEDVM: AnyObject, DetailConfiguring {

    var delegate: DetailLEDVMDelegate? { get set }

    func start()

    func turnOnGreen()
    func flashGreen()
    func turnOnRed()
    func flashRed()
    func turnOnBlue()
    func flashBlue()

    func turnOffLEDs()
}

public protocol DetailLEDVMDelegate: AnyObject {
    func refreshView()
}
