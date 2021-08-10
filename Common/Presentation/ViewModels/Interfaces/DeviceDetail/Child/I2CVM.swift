//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol I2CVM: AnyObject, DetailConfiguring {

    var delegate: I2CVMDelegate? { get set }

    var selectedSize: I2CSize { get }
    var selectedSizeOptions: [I2CSize] { get }
    var deviceAddressInput: String { get }
    var deviceRegisterInput: String { get }
    var bytesToWriteInput: String { get }

    var bytesReadFromDeviceOutput: String { get }

    func userRequestedReadBytes()
    func userRequestedWriteBytes()

    func userSetDeviceAddress(_ newValue: String)
    func userSetRegisterAddress(_ newValue: String)
    func userSetBytesToWrite(_ newValue: String)

}

public protocol I2CVMDelegate: AnyObject {
    func refreshView()
    func showInvalidDeviceAddressInputHint()
    func showInvalidRegisterInputHint()
    func showInvalidWriteHint()

    func didPerformWriteOrReadOperation()
}
