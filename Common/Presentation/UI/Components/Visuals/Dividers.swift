//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DividerPadded: View {

    init(_ vertical: CGFloat = 5, opacity: CGFloat = 1) {
        self.padding = vertical
        self.opacity = opacity
    }

    var padding: CGFloat
    var opacity: CGFloat

    var body: some View {
        Divider()
            .padding(.vertical, padding)
            .opacity(opacity)
    }
}


struct VerticalDivider: View {

    var body: some View {
        Rectangle().fill(Color.secondary.opacity(0.2)).frame(width: 1).frame(maxHeight: .infinity)
            .padding(.horizontal, (.detailBlockColumnSpacing - 1) / 2)
    }
}
