//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct LabeledItem<Content: View>: View {

    @Environment(\.sizeCategory) private var typeSize

    var label: String
    var content: Content
    var maxWidth: CGFloat = 100
    var alignment: VerticalAlignment = .center
    var contentAlignment: Alignment = .leading
    var shouldCompressOnMac: Bool = false

    var body: some View {
        if typeSize.isAccessibilityCategory {

            VStack(alignment: .leading, spacing: 10) {
                textLabel.frame(maxWidth: .infinity, alignment: .leading)
                content.frame(maxWidth: .infinity, alignment: contentAlignment)
            }
        } else {

            HStack(alignment: alignment, spacing: 10) {
                if shouldCompressOnMac {
                    textLabel
                        .frame(maxWidth: maxWidth, alignment: .leading)
                        .fixedSize()
                } else {
                    textLabel
                        .frame(width: maxWidth, alignment: .leading)
                }
                content
                    .frame(maxWidth: .infinity, alignment: contentAlignment)
                    .fixedSize(horizontal: shouldCompressOnMac, vertical: false)
            }
        }
    }

    private var textLabel: some View {
        Text(label)
            .fontSmall(weight: .medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
    }
}

struct LabeledColorKeyedItem<Content: View>: View {

    @Environment(\.sizeCategory) private var typeSize

    var color: Color
    var label: String
    var content: Content
    var maxWidth: CGFloat = 100
    var alignment: VerticalAlignment = .center
    var contentAlignment: Alignment = .leading

    var body: some View {
        if typeSize.isAccessibilityCategory {

            VStack(alignment: .leading, spacing: 10) {
                colorPair.frame(maxWidth: .infinity, alignment: .leading)
                content.frame(maxWidth: .infinity, alignment: contentAlignment)
            }

        } else {

            HStack(alignment: alignment, spacing: 10) {
                colorPair.frame(width: maxWidth, alignment: .leading)
                content.frame(maxWidth: .infinity, alignment: contentAlignment)
            }
        }
    }

    private var colorPair: some View {

        HStack(spacing: 10) {
            let size: CGFloat = typeSize.isAccessibilityCategory ? 25 : 11
            Circle().fill(color)
                .frame(width: size, height: size)

            textLabel
        }
    }

    private var textLabel: some View {
        Text(label)
            .fontSmall(weight: .medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
    }
}

struct LabeledButtonItem<Content: View>: View {
    
    @Environment(\.sizeCategory) private var typeSize

    var label: String
    var content: Content
    var maxWidth: CGFloat = 100
    var alignment: VerticalAlignment = .center
    var onTap: () -> Void

    var body: some View {
        HStack(alignment: alignment, spacing: 10) {
            Button(label) { onTap() }
            .fontSmall(weight: .medium)

            .multilineTextAlignment(.leading)
            .frame(width: maxWidth, alignment: .leading)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
