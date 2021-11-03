//  Created by Ryan Ferrell.
//  Copyright © 2021 MbientLab. All rights reserved.

import SwiftUI

extension View {

    func background<T>(color: Color, in shape: T) -> some View where T : InsettableShape {
        self.background(shape.fill(color))
    }
}
