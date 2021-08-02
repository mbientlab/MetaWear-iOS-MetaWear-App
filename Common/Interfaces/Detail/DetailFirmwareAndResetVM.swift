//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol DetailFirmwareAndResetVM: AnyObject, DetailConfiguring {

    var delegate: DetailFirmwareAndResetVMDelegate? { get set }
    var firmwareUpdateStatus: String { get }

    func start()
}

public protocol DetailFirmwareAndResetVMDelegate: AnyObject {
    func refreshView()
}
