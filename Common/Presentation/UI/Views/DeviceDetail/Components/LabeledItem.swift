//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct LabeledItem<Content: View>: View {

    var label: String
    var content: Content
    var maxWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        HStack {
            Text(label)
                .frame(width: maxWidth * .blockLabelColumnScreenWidth())

            content
                .frame(maxWidth: .infinity)
        }
    }
}
