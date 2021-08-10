//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            .init(translationX: effectSize * sin(position * 2 * .pi), y: 0)
        )
    }

    init(shakes: Int, effectSize: CGFloat = -30) {
        position = CGFloat(shakes)
        self.effectSize = effectSize
    }

    var effectSize: CGFloat
    var position: CGFloat
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }
}
