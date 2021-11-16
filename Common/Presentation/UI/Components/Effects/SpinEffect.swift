//
//  SpinEffect.swift
//  SpinEffect
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SpinEffect: GeometryEffect {

    var degrees: CGFloat

    var animatableData: CGFloat {
        get { degrees }
        set { degrees = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        return .init(CGAffineTransform(translationX: halfWidth, y: halfHeight)
            .rotated(by: degrees * .pi / 180)
            .translatedBy(x: -halfWidth, y: -halfHeight))
    }
}

struct SpinEffectWithReporter: GeometryEffect {

    @Binding var spinProgress: CGFloat
    var degrees: CGFloat

    var animatableData: CGFloat {
        get { degrees }
        set { degrees = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        defer { DispatchQueue.main.async { spinProgress = degrees } }
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        return .init(CGAffineTransform(translationX: halfWidth, y: halfHeight)
            .rotated(by: degrees * .pi / 180)
            .translatedBy(x: -halfWidth, y: -halfHeight))
    }
}
