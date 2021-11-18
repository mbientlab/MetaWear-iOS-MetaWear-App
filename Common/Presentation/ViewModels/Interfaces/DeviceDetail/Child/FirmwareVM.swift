//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol FirmwareVM: AnyObject, DetailConfiguring {

    var delegate: FirmwareVMDelegate? { get set }
    
    var firmwareUpdateStatus: String { get }
    var firmwareRevision: String { get }
    var offerUpdate: Bool { get }
    var hasInternetConnection: Bool { get }

    // Intents
    func userRequestedCheckForFirmwareUpdates()
    func userRequestedUpdateFirmware()
}

public protocol FirmwareVMDelegate: AnyObject {
    func refreshView()
}
