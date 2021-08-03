//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol DetailFirmwareVM: AnyObject, DetailConfiguring {

    var delegate: DetailFirmwareAndResetVMDelegate? { get set }
    var firmwareUpdateStatus: String { get }
    var firmwareRevision: String { get }

    func start()

    // Intents
    func userRequestedCheckForFirmwareUpdates()
    func userRequestedUpdateFirmware()
}

public protocol DetailFirmwareAndResetVMDelegate: AnyObject {
    func refreshView()
    func presentAlert(title: String, message: String)
}
