//
//  Fonts.swift
//  Fonts
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

// MARK: - LargeTitle

struct MWLargeTitle: AdaptiveFontViewModifier {
#if os(iOS)
static let fontSize: CGFloat = 28
#else
static let fontSize: CGFloat = 18
#endif
    @ScaledMetric(relativeTo: .title) var size = Self.fontSize
    @Environment(\.fontFace) var face
    var weight: Font.Weight
    var design: Font.Design
    var monospacedDigit: Bool

    func body(content: Content) -> some View {
        var font = adaptiveFont()
        if monospacedDigit {
            font = font.monospacedDigit()
        }
        return content.font(font)
    }
}

extension View {

    func fontLargeTitle(weight: Font.Weight = .regular,
                        design: Font.Design = .rounded,
                        monospacedDigit: Bool = false
    ) -> some View {
        self.modifier(MWLargeTitle(weight: weight, design: design, monospacedDigit: monospacedDigit))
    }
}

// MARK: - Larger Body

struct MWLarger: AdaptiveFontViewModifier {
    #if os(iOS)
    static let fontSize: CGFloat = 19
    #else
    static let fontSize: CGFloat = 16
    #endif
    @ScaledMetric(relativeTo: .headline) var size = Self.fontSize
    @Environment(\.fontFace) var face
    var weight: Font.Weight
    var design: Font.Design
    var monospacedDigit: Bool

    func body(content: Content) -> some View {
        var font = adaptiveFont()
        if monospacedDigit {
            font = font.monospacedDigit()
        }
        return content.font(font)
    }
}

extension View {

    func fontLarger(weight: Font.Weight = .regular,
                  design: Font.Design = .rounded,
                  monospacedDigit: Bool = false
    ) -> some View {
        self.modifier(MWLarger(weight: weight, design: design, monospacedDigit: monospacedDigit))
    }
}

// MARK: - Body

struct MWBody: AdaptiveFontViewModifier {
    #if os(iOS)
    static let fontSize: CGFloat = 17
    #else
    static let fontSize: CGFloat = 14
    #endif
    @ScaledMetric(relativeTo: .body) var size = Self.fontSize
    @Environment(\.fontFace) var face
    var weight: Font.Weight
    var design: Font.Design
    var monospacedDigit: Bool

    func body(content: Content) -> some View {
        var font = adaptiveFont()
        if monospacedDigit {
            font = font.monospacedDigit()
        }
        return content.font(font)
    }
}

extension View {

    func fontBody(weight: Font.Weight = .regular,
                  design: Font.Design = .rounded,
                  monospacedDigit: Bool = false
    ) -> some View {
        self.modifier(MWBody(weight: weight, design: design, monospacedDigit: monospacedDigit))
    }
}

// MARK: - Minor

struct MWSmall: AdaptiveFontViewModifier {
#if os(macOS)
static let fontSize: CGFloat = 12
#elseif os(iOS)
    static let fontSize: CGFloat = 15
#endif
    @ScaledMetric(relativeTo: .subheadline) var size = Self.fontSize
    @Environment(\.fontFace) var face
    var weight: Font.Weight
    var design: Font.Design
    var monospacedDigit: Bool

    func body(content: Content) -> some View {
        var font = adaptiveFont()
        if monospacedDigit {
            font = font.monospacedDigit()
        }
        return content.font(font)
    }
}

extension View {

    func fontSmall(weight: Font.Weight = .regular,
                   design: Font.Design = .rounded,
                   monospacedDigit: Bool = false
    ) -> some View {
        self.modifier(MWSmall(weight: weight, design: design, monospacedDigit: monospacedDigit))
    }
}

// MARK: - Very Small

struct MWVerySmall: AdaptiveFontViewModifier {
#if os(macOS)
static let fontSize: CGFloat = 11
#elseif os(iOS)
    static let fontSize: CGFloat = 14
#endif
    @ScaledMetric(relativeTo: .caption) var size = Self.fontSize
    @Environment(\.fontFace) var face
    var weight: Font.Weight
    var design: Font.Design
    var monospacedDigit: Bool
    var lowercaseSmallCaps: Bool

    func body(content: Content) -> some View {
        var font = adaptiveFont()
        if monospacedDigit {
            font = font.monospacedDigit()
        }
        if lowercaseSmallCaps {
            font = font.lowercaseSmallCaps()
        }
        return content.font(font)
    }
}

extension View {

    func fontVerySmall(weight: Font.Weight = .regular,
                       design: Font.Design = .default,
                       monospacedDigit: Bool = false,
                       lowercaseSmallCaps: Bool = false
    ) -> some View {
        self.modifier(MWSmall(weight: weight, design: design, monospacedDigit: monospacedDigit))
    }
}

