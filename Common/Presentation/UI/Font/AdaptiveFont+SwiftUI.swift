//
//  AdaptiveFont+SwiftUI.swift
//  AdaptiveFont+SwiftUI
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

protocol AdaptiveFontViewModifier: ViewModifier {
    var face: FontFace { get }
    var size: CGFloat { get }
    var weight: Font.Weight { get }
    var design: Font.Design { get }
}

extension AdaptiveFontViewModifier {

    func adaptiveFont() -> Font {
        if face == .system {
            return .system(size: size, weight: weight, design: design)
        } else {
            return .custom(fontFor(weight, design), size: size)
        }
    }

    private func fontFor(_ weight: Font.Weight, _ design: Font.Design) -> String {

        if design == .monospaced { return face.monospaceFont }

        switch weight {

            case .light: fallthrough
            case .thin: fallthrough
            case .ultraLight: fallthrough
            case .regular:
                return face.font

            case .black: fallthrough
            case .bold: fallthrough
            case .heavy: fallthrough
            case .semibold: fallthrough
            case .medium:
                return face.boldFont

            default: return face.font
        }
    }
}

extension Font {

    static func adaptiveFont(rendering: FontFace, size: CGFloat, weight: Font.Weight, design: Font.Design) -> Font {

        func fontFor(_ weight: Font.Weight, _ design: Font.Design) -> String {

            if design == .monospaced { return rendering.monospaceFont }

            switch weight {

                case .light: fallthrough
                case .thin: fallthrough
                case .ultraLight: fallthrough
                case .regular:
                    return rendering.font

                case .black: fallthrough
                case .bold: fallthrough
                case .heavy: fallthrough
                case .semibold: fallthrough
                case .medium:
                    return rendering.boldFont

                default: return rendering.font
            }
        }

        if rendering == .system {
            return .system(size: size, weight: weight, design: design)
        } else {
            return .custom(fontFor(weight, design), size: size)
        }
    }
}

