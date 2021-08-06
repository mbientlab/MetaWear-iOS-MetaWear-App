//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DetailsBlockCard<Content: View>: View {

    @Environment(\.colorScheme) var scheme

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

    private var title: String
    private var content: Content
    private var image: Image
    private var iconDescription: String

    var body: some View {
        VStack(spacing: 1) {
            cardTitle

            content
                .frame(maxWidth: .infinity)
                .blockify()
        }
    }

    private var cardTitle: some View {
        HStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: .detailsBlockHeaderIcon, height: .detailsBlockHeaderIcon)
                .accessibilityLabel(iconDescription)

            Text(title)
                .fontWeight(scheme == .light ? .medium : .regular)
                .font(.subheadline)
                .fixedSize(horizontal: true, vertical: false)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.secondary)
        .padding(.horizontal, .detailBlockContentPadding + 5)
        .flipsForRightToLeftLayoutDirection(true)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
    }
}

struct TitlelessDetailsBlockCard<Content: View>: View {

    var content: Content

    var body: some View {
        VStack(spacing: 4) {
            content
                .frame(maxWidth: .infinity)
                .blockify()
        }
        .frame(maxWidth: .infinity)

    }
}
