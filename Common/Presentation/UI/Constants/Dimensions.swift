//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public extension CGFloat {
    static let detailBlockCorners: CGFloat = 10
    static let detailBlockOuterPadding: CGFloat = 8
    static let detailBlockContentPadding: CGFloat = 17
    static let detailBlockInnerContentSize: CGFloat = .detailBlockWidth - .detailBlockOuterPadding + .detailBlockContentPadding

    static let cardVSpacing: CGFloat = 13


    static let detailsGraphHeight: CGFloat = 200

    #if os(iOS)
    static let detailsBlockHeaderIcon: CGFloat = 19
    #elseif os(macOS)
    static let detailsBlockHeaderIcon: CGFloat = 16
    #endif

    static let standardVStackSpacing: CGFloat = 6
    static let cardGridSpacing: CGFloat = 25
}

extension CGFloat {
    static let windowMinHeight: CGFloat = 400
    static let windowWidthMin: CGFloat = .sidebarEstimate + .cardGridSpacing + detailBlockWidth + .cardGridSpacing + detailBlockWidth + .cardGridSpacing
    fileprivate static let sidebarEstimate = CGFloat(200)

    #if os(iOS)
    static let detailBlockWidth: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad { return 400 }
        else { return UIScreen.main.bounds.width }
    }()
    #elseif os(macOS)
    static let detailBlockWidth: CGFloat = 370
    #endif
}


