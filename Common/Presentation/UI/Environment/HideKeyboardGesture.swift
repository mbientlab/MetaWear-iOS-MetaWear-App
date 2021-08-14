//  Created by Ryan on 8/15/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct HideKeyboardGestureModifier: ViewModifier {
    @Environment(\.keyboardIsShown) var keyboardIsShown

    func body(content: Content) -> some View {
        content
            .gesture(TapGesture().onEnded {
                UIApplication.shared.resignCurrentResponder()
            }, including: keyboardIsShown ? .all : .none)
    }
}

extension UIApplication {
    func resignCurrentResponder() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

extension View {

    /// Assigns a tap gesture that dismisses the first responder only when the keyboard is visible to the KeyboardIsShown EnvironmentKey
    func dismissKeyboardOnTap() -> some View {
        modifier(HideKeyboardGestureModifier())
    }

    /// Shortcut to close in a function call
    func resignCurrentResponder() {
        UIApplication.shared.resignCurrentResponder()
    }
}
