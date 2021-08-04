//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DetailsBlockCard<Content: View>: View {

    init(title: String,
         image: Image,
         iconDescription: String,
         content: Content) {
        self.title = title
        self.image = image
        self.iconDescription = iconDescription
        self.content = content
    }

    init(title: String, symbol: SFSymbol, content: Content) {
        self.title = title
        self.image = symbol.image()
        self.iconDescription = symbol.accessibilityDescription
        self.content = content
    }

    var title: String
    var content: Content
    var image: Image
    var iconDescription: String

    var body: some View {
        VStack {
            cardTitle
            content
        }
        .blockify()
    }

    private var cardTitle: some View {
        HStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: .detailsBlockHeaderIcon, height: .detailsBlockHeaderIcon)
                .accessibilityLabel(iconDescription)

            Text(title)
        }
        .flipsForRightToLeftLayoutDirection(true)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
    }
}
