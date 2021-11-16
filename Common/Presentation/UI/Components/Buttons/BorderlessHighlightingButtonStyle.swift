//
//  BorderlessHighlightingButtonStyle.swift
//  BorderlessHighlightingButtonStyle
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct BorderlessHoverHighlightButtonStyle: ButtonStyle {

    /// True to continually show the "highlight" color
    var isActive: Bool = false

    /// Normal, non-highlighted state. Nil to accept the current environment's foreground color.
    var foreground: Color? = nil

    /// Mouse-over color
    var highlightColor: Color = .accentColor

    /// Activated non-moused over color
    var activeColor: Color = .accentColor.opacity(0.9)

    /// Pass 1 for no scaling
    var scaleOnPressFactor: CGFloat = 0.9

    /// Padding around label. Default is 5. Slightly enlarges the hit target.
    var padding: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        Style(config: configuration,
              isActive: isActive,
              foreground: foreground,
              highlightColor: highlightColor,
              activeColor: activeColor,
              scaleOnPressFactor: scaleOnPressFactor,
              padding: padding
        )
            .contentShape(Rectangle())
    }

    private struct Style: View {
        @Environment(\.colorScheme) var colorScheme

        @State var isHovering = false
        var config: Configuration
        var isActive: Bool = false
        var foreground: Color?
        var highlightColor: Color
        var activeColor: Color
        var scaleOnPressFactor: CGFloat
        var padding: CGFloat? = nil

        var body: some View {
            config.label
                .foregroundColor(foregroundColor())
                .scaleEffect(config.isPressed ? scaleOnPressFactor : 1)
                .padding(padding ?? 0)
                .whenHovered { state in  isHovering = state }
                .animation(.easeOut(duration: 0.1), value: config.isPressed)
                .animation(.easeOut(duration: 0.3), value: isActive)
                .animation(.easeOut(duration: 0.1), value: isHovering)
        }

        func foregroundColor() -> Color? {
            if isHovering { return highlightColor }
            if isActive { return activeColor }
            else { return foreground }
        }
    }
}
