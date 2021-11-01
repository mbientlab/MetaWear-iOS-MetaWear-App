//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DetailsBlockCard<Content: View>: View {

    @Environment(\.colorScheme) private var scheme
    var details: Namespace.ID

    init(group: DetailGroup, namespace: Namespace.ID, showTitle: Bool = true, content: @escaping () -> Content) {
        self.title = group.title
        self.image = group.symbol.image()
        self.iconDescription = group.symbol.accessibilityDescription
        self.content = content
        self.tag = group.id
        self.details = namespace
        self.showTitle = showTitle
        self.width = .detailBlockWidth
    }

    private var title: String
    private var content: () -> Content
    private var image: Image
    private var iconDescription: String
    private var tag: AnyHashable
    private var width: CGFloat
    private var showTitle: Bool

    var body: some View {
        VStack(spacing: 1) {
            cardTitle
                .opacity(showTitle ? 1 : 0)
                .zIndex(10)

            content()
                .frame(maxWidth: .infinity)
                .blockify()
        }
        .frame(width: width)
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(Double(DetailGroup.allCases.endIndex - (tag as? Int ?? 0)))
        .accessibilityLabel(title)
        .accessibilityLinkedGroup(id: "details", in: details)
    }

    private var cardTitle: some View {
#if os(iOS)
        HStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: .detailsBlockHeaderIcon, height: .detailsBlockHeaderIcon)
                .accessibilityLabel(iconDescription)

            Text(title)
                .fontSmall(weight: scheme == .light ? .medium : .regular)
                .fixedSize(horizontal: true, vertical: false)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.mwSecondary)
        .padding(.horizontal, .detailBlockContentPadding + 5)
        .flipsForRightToLeftLayoutDirection(true)
        .accessibilityHidden(true)
#else
        VStack {
            HStack(spacing: .detailBlockContentPadding) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: .detailsBlockHeaderIcon, height: .detailsBlockHeaderIcon)
                    .accessibilityLabel(iconDescription)
                    .foregroundColor(Color.mwSecondary)

                Text(title)
                    .fontLarger(weight: scheme == .light ? .medium : .regular)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer()
            }
            .padding(.detailBlockCorners * 1.25)
            .background(color: .groupedListBackground, in: RoundedRectangle(cornerRadius: .detailBlockCorners, style: .continuous))
            .shadow(color: macShadowColor, radius: 11, x: 3, y: 7)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, .detailBlockContentPadding)
        .flipsForRightToLeftLayoutDirection(true)
        .accessibilityHidden(true)
#endif

    }

    @Environment(\.colorScheme) private var colorScheme
    private var macShadowColor: Color {
        colorScheme == .light
        ? .black.opacity(0.1)
        : .black.opacity(0.15)
    }
}

struct TitlelessDetailsBlockCard<Content: View>: View {

    var tag: AnyHashable
    var content: Content

    var body: some View {
        VStack(spacing: 4) {
            content
                .frame(maxWidth: .infinity)
                .blockify()
        }
        .frame(maxWidth: .infinity)
        .id(tag)
    }
}
