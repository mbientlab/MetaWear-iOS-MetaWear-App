//  Created by Ryan Ferrell on 8/13/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

/// Default: leading alignment
struct SmallUnitLabel<Key: WidthKey>: View {

    var string: String
    var equalWidthKey: Key.Type
    var width: CGFloat
    var alignment: Alignment = .leading

    var body: some View {
        Text(string)
            .fontVerySmall()
            .fixedSize(horizontal: true, vertical: false)
            .foregroundColor(.mwSecondary)
            .padding(.leading, 5)
            .matchWidths(to: equalWidthKey, width: width, alignment: alignment)
    }
}

struct SmallUnitLabelFixed: View {

    init(_ string: String) {
        self.string = string
    }
    var string: String

    var body: some View {
        Text(string)
            .fontVerySmall()
            .fixedSize(horizontal: true, vertical: false)
            .multilineTextAlignment(.leading)
            .foregroundColor(.mwSecondary)
            .padding(.leading, 5)
    }
}

struct PublicUnitWidthKey: WidthKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
