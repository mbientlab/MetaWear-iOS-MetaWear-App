//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWiBeaconVM: IBeaconVM {

    public private(set) var iBeaconIsOn = false

    // Identity
    public weak var delegate: IBeaconVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
}

extension MWiBeaconVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        delegate?.refreshView()
    }
}

public extension MWiBeaconVM {

    func userRequestedStopIBeacon() {
        guard let board = device?.board else { return }
        mbl_mw_ibeacon_disable(board)
        iBeaconIsOn = false
        delegate?.refreshView()
    }

    func userRequestedStartIBeacon() {
        guard let board = device?.board else { return }

        mbl_mw_ibeacon_set_major(board, 78)
        mbl_mw_ibeacon_set_minor(board, 7453)
        mbl_mw_ibeacon_set_period(board, 15027)
        mbl_mw_ibeacon_set_rx_power(board, -55)
        mbl_mw_ibeacon_set_tx_power(board, -12)
        safelyLoadIdentifierIntoBoard(board)

        mbl_mw_ibeacon_enable(board)

        iBeaconIsOn = true
        delegate?.refreshView()
        parent?.alerts.presentAlert(title: "iBeacon", message: "You must disconnect from your MetaWear before it is visible as an iBeacon.")
    }
}

// MARK: - Helpers

private extension MWiBeaconVM {

    // The original sample app left a dangling pointer in memory like this:
    //        var array: [UInt8] = ...
    //        let up: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.init(&array)
    //        mbl_mw_ibeacon_set_uuid(board, up)
    //
    // For an explanation of this aspect of unsafe Swift,
    // see the warning in Apple's [documentation](https://developer.apple.com/documentation/swift/unsafemutablepointer)
    //
    func safelyLoadIdentifierIntoBoard(_ board: OpaquePointer) {
        let uuid = UUID().uuidString
        let array: [UInt8] = Array(uuid.utf8)

        let count = array.count
        let uploadPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        uploadPointer.initialize(repeating: 0, count: count)

        defer {
            uploadPointer.deinitialize(count: count)
            uploadPointer.deallocate()
        }

        uploadPointer.pointee = array[0]
        for index in 1..<array.endIndex {
            uploadPointer.advanced(by: 1).pointee = array[index]
        }

        mbl_mw_ibeacon_set_uuid(board, uploadPointer)
    }
}
