//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

#if canImport(UIKit)
import UIKit
extension UIApplication {
    static func firstKeyWindow() -> UIWindow? {
        UIApplication.shared.windows.first(where: \.isKeyWindow)
    }
}
#endif
