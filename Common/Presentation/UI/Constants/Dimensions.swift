//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

extension CGFloat {
    static let detailBlockCorners: CGFloat = 10
    static let detailBlockOuterPadding: CGFloat = 8
    static let detailBlockContentPadding: CGFloat = 17

    static let cardVSpacing: CGFloat = 13

    static let detailsBlockHeaderIcon: CGFloat = 19

    static let detailsGraphHeight: CGFloat = 120

    static func blockLabelColumnScreenWidth() -> CGFloat {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ?
        0.2 : 0.25
#elseif os(macOS)
        return 0.2
#endif
    }
}
