//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol I2CBusVM: AnyObject, DetailConfiguring {

    var delegate: I2CBusVMDelegate? { get set }

    var selectedSize: I2CSize { get }
    var sizeOptions: [I2CSize] { get }
    var deviceAddressInput: String { get }
    var deviceRegisterInput: String { get }
    var bytesToWriteInput: String { get }

    var bytesReadFromDeviceOutput: String { get }

    func userRequestedReadBytes()
    func userRequestedWriteBytes()

    func userSelectedSize(_ newValue: I2CSize)
    func userSetDeviceAddress(_ newValue: String)
    func userSetRegisterAddress(_ newValue: String)
    func userSetBytesToWrite(_ newValue: String)

}

public protocol I2CBusVMDelegate: AnyObject {
    func refreshView()
    func showInvalidDeviceAddressInputHint()
    func showInvalidRegisterInputHint()
    func showInvalidWriteHint()

    func didPerformWriteOrReadOperation()
}
