//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct LabeledItem<Content: View>: View {

    var label: String
    var content: Content
    var maxWidth: CGFloat = UIScreen.main.bounds.width
    var alignment: VerticalAlignment = .firstTextBaseline

    var body: some View {
        HStack(alignment: alignment, spacing: 10) {
            Text(label)
                .fontWeight(.medium)
                .font(.subheadline)
                .foregroundColor(.secondary)

                .multilineTextAlignment(.leading)
                .frame(width: maxWidth * .blockLabelColumnScreenWidth(), alignment: .leading)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
