//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public protocol WidthKey: PreferenceKey where Value == CGFloat { }

public extension View {

    func matchWidths<Key: WidthKey>(
        to key: Key.Type,
        width: CGFloat, alignment: Alignment
    ) -> some View {

        measureWidth(key: key)
            .frame(width: width, alignment: alignment)
    }

    func measureWidth<Key: WidthKey>(key: Key.Type) -> some View {
        background(GeometryReader { geo in
            Color.clear
                .preference(key: key, value: geo.size.width)
        })
    }
}
