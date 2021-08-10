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
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 0)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: .detailBlockCorners)
    }

    private var fill: Color {
        .blockPlatterFill
    }

    private var stroke: Color {
        .blockPlatterStroke
    }
}
