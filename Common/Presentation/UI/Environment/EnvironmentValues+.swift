//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    var allowBluetoothRequests: Bool {
        get { return self[AllowBluetoothRequestsKey.self] }
        set { self[AllowBluetoothRequestsKey.self] = newValue }
    }
}

private struct AllowBluetoothRequestsKey: EnvironmentKey {
    static let defaultValue: Bool = true
}
