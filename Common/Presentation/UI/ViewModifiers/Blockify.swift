//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

extension View {

    func blockify() -> some View {
        modifier(Blockify())
    }
}

struct Blockify: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.detailBlockContentPadding)
            .background(DetailsBlockPlatter())
            .padding(.detailBlockOuterPadding)
    }
}

struct DetailsBlockPlatter: View {

    var body: some View {
        ZStack {
            shape.fill(fill)
            shape.stroke(stroke, lineWidth: 1)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 0)
    }

    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: .detailBlockCorners)
    }

    var fill: Color {
#if os(iOS)
        return Color(.secondarySystemGroupedBackground)
#endif
    }

    var stroke: Color {
#if os(iOS)
        return Color(.quaternaryLabel)
#endif
    }
}
