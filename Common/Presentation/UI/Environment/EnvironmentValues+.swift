//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    var scrollProxy: ScrollViewProxy? {
        get { return self[ScrollViewProxyKey.self] }
        set { self[ScrollViewProxyKey.self] = newValue }
    }

    var contentHeight: CGFloat {
        get { return self[ContentHeightEVK.self] }
        set { self[ContentHeightEVK.self] = newValue }
    }

    var hasUserFocus: Bool {
        get { return self[HasUserFocusKey.self] }
        set { self[HasUserFocusKey.self] = newValue }
    }

    var fontFace: FontFace {
        get { return self[FontFaceKey.self] }
        set { self[FontFaceKey.self] = newValue }
    }

    var keyboardIsShown: Bool {
        get { return self[KeyboardIsShownEVK.self] }
        set { self[KeyboardIsShownEVK.self] = newValue }
    }

    var parentNamespace: Namespace.ID? {
        get { return self[ParentNamespaceEVK.self] }
        set { self[ParentNamespaceEVK.self] = newValue }
    }
}

private struct ScrollViewProxyKey: EnvironmentKey {
    static let defaultValue: ScrollViewProxy? = nil
}

private struct ContentHeightEVK: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

private struct HasUserFocusKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct FontFaceKey: EnvironmentKey {
    static let defaultValue: FontFace = .system
}

private struct KeyboardIsShownEVK: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct ParentNamespaceEVK: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}
