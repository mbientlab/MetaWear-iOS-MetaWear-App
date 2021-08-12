//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWI2CBusVM: I2CBusVM {

    // Inputs
    public private(set) var selectedSize: I2CSize = .byte
    public let sizeOptions: [I2CSize] = I2CSize.allCases

    public private(set) var deviceAddressInput = ""
    public private(set) var deviceRegisterInput = ""
    public private(set) var bytesToWriteInput = ""

    // Output
    public private(set) var bytesReadFromDeviceOutput = " "

    // Identity
    public weak var delegate: I2CBusVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
}

extension MWI2CBusVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        delegate?.refreshView()
    }
}

// MARK: - Intents

public extension MWI2CBusVM {

    func userSelectedSize(_ newValue: I2CSize) {
        selectedSize = newValue
        delegate?.refreshView()
    }

    func userSetDeviceAddress(_ newValue: String) {
        deviceAddressInput = newValue
        delegate?.refreshView()
    }

    func userSetRegisterAddress(_ newValue: String) {
        deviceRegisterInput = newValue
        delegate?.refreshView()
    }

    func userSetBytesToWrite(_ newValue: String) {
        bytesToWriteInput = newValue
        delegate?.refreshView()
    }
}

public extension MWI2CBusVM {

    func userRequestedReadBytes() {
        guard let (deviceAddress, registerAddress) = getValidDeviceAndRegisterAddresses() else { return }
        guard let board = device?.board else { return }

        let length: UInt8 = selectedSize.length
        let signal = mbl_mw_i2c_get_data_signal(board, length, 0)!

        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let bytes: [UInt8] = obj!.pointee.valueAs()
            let _self: MWI2CBusVM = bridge(ptr: context!)

            DispatchQueue.main.async {
                _self.bytesReadFromDeviceOutput = bytes.description
                _self.delegate?.refreshView()
            }
        }

        var parameters = MblMwI2cReadParameters(device_addr: deviceAddress, register_addr: registerAddress)
        mbl_mw_datasignal_read_with_parameters(signal, &parameters)

        delegate?.didPerformWriteOrReadOperation()
    }

    func userRequestedWriteBytes() {
        guard let (deviceAddress, registerAddress) = getValidDeviceAndRegisterAddresses() else { return }

        guard var writeData = Int32(bytesToWriteInput.drop0xPrefix, radix: 16) else {
            bytesToWriteInput = ""
            delegate?.showInvalidWriteHint()
            return
        }

        guard let board = device?.board else { return }

        let length: UInt8 = selectedSize.length
        let array = Array(Data(bytes: &writeData, count: Int(length)))
        mbl_mw_i2c_write(board, deviceAddress, registerAddress, array, length)

        bytesToWriteInput = ""
        delegate?.didPerformWriteOrReadOperation()
        delegate?.refreshView()
    }

}

// MARK: - Helpers

private extension MWI2CBusVM {

    func getValidDeviceAndRegisterAddresses() -> (device: UInt8, register: UInt8)? {
        guard let deviceAddress = UInt8(deviceAddressInput.drop0xPrefix, radix: 16) else {
            deviceAddressInput = ""
            delegate?.showInvalidDeviceAddressInputHint()
            return nil
        }

        guard let registerAddress = UInt8(deviceRegisterInput.drop0xPrefix, radix: 16) else {
            deviceRegisterInput = ""
            delegate?.showInvalidRegisterInputHint()
            return nil
        }

        return (deviceAddress, registerAddress)
    }
}
