//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp

public protocol LogDownloadHandler {

    func reportProgress(board: OpaquePointer, to delegate: LogDownloadHandlerDelegate, parent: DeviceDetailsCoordinator?)

}

public protocol LogDownloadHandlerDelegate: AnyObject {

    /// Data transferred, now cleaning up logs. You can mark the download as complete and refresh statistics about the data collected.
    func initialDataTransferDidComplete()

    func receivedUnknownEntry(context: UnsafeMutableRawPointer?, id: UInt8, epoch: Int64, data: UnsafePointer<UInt8>?, length: UInt8)
    
    func receivedUnhandledEntry(context: UnsafeMutableRawPointer?, data: UnsafePointer<MblMwData>?)
}
