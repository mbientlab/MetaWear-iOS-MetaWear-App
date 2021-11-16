//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class GPIOSUIVC: MWGPIOVM, ObservableObject {
    
    public override init() {
        super.init()
        self.delegate = self
    }
    
#if os(iOS)
    private lazy var haptic = UINotificationFeedbackGenerator()
#endif
    
}

extension GPIOSUIVC: GPIOVMDelegate {
    public func indicateCommandWasSentToBoard() {
#if os(iOS)
        haptic.notificationOccurred(.success)
#endif
    }
    
    public func refreshView() {
        self.objectWillChange.send()
    }
}
