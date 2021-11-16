//
//  AdaptiveFont+AppKit.swift
//  AdaptiveFont+AppKit
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import AppKit

extension NSFont {

    static func adaptiveFont(for type: FontFace, size: CGFloat, weight: NSFont.Weight = .regular, design: NSFontDescriptor.SystemDesign = .rounded) -> NSFont {

        switch type {

            case .system:
                guard let descriptor = NSFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(design),
                let font = NSFont(descriptor: descriptor, size: size)
                else { return .systemFont(ofSize: size, weight: weight)  }
                return font

            case .openDyslexic: fallthrough
            case .chalkboard:
                let fontName = dyslexicFontNameFor(type: type, weight, design)
                guard let font = NSFont(name: fontName, size: size)
                else { return .systemFont(ofSize: size, weight: weight) }
                return font
        }
    }

    private static func dyslexicFontNameFor(type: FontFace, _ weight: NSFont.Weight, _ design: NSFontDescriptor.SystemDesign) -> String {

        if design == .monospaced { return type.monospaceFont }

        switch weight {

            case .light: fallthrough
            case .thin: fallthrough
            case .ultraLight: fallthrough
            case .regular:
                return type.font

            case .black: fallthrough
            case .bold: fallthrough
            case .heavy: fallthrough
            case .semibold: fallthrough
            case .medium:
                return type.boldFont

            default: return type.font
        }
    }
}
