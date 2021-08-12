//  Created by Ryan Ferrell on 8/12/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

public class I2CBusSUIVC: MWI2CBusVM, ObservableObject {

    // Exact values are meaningless. Any change drives an animation.
    @Published var showDeviceInputInvalid = false
    @Published var showRegisterInputInvalid = false
    @Published var showWriteInputInvalid = false

#if os(iOS)
    private lazy var haptic = UINotificationFeedbackGenerator()
#endif

    public override init() {
        super.init()
        self.delegate = self
    }
}

extension I2CBusSUIVC: I2CBusVMDelegate {

    public func refreshView() {
        objectWillChange.send()
    }

    public func showInvalidDeviceAddressInputHint() {
        showDeviceInputInvalid.toggle()
    }

    public func showInvalidRegisterInputHint() {
        showDeviceInputInvalid.toggle()
    }

    public func showInvalidWriteHint() {
        showDeviceInputInvalid.toggle()
    }

    public func didPerformWriteOrReadOperation() {
        #if os(iOS)
        haptic.notificationOccurred(.success)
        #endif
    }
}
