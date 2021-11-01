//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

extension View {

    func background<T>(color: Color, in shape: T) -> some View where T : InsettableShape {
        self.background(shape.fill(color))
    }
}
