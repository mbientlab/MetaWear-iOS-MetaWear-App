//
//  Color.swift
//  Color
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

extension Color {

    static let toastPillBackground = Color("toastPillBackground")

    static let ledRed = Color("red")
    static let ledGreen = Color("green")
    static let ledBlue = Color("blue")

    static let plotPink = Color("plotPink")
    static let plotGold = Color("plotGold")
    static let plotBlue = Color("plotBlue")
    static let plotGray = Color("plotGray")
    static let plotBackground = Color("plotBackground")

    static let startScreen = Color("StartScreen")

#if os(iOS)
    static let groupedListBackground = Color(.systemGroupedBackground)
    static let reversedTextColor = Color(.systemBackground)
    static let ledOffPlatter = Color(.systemGray3)
    static let blockPlatterFill = Color(.secondarySystemGroupedBackground)
    static let blockPlatterStroke = Color(.quaternaryLabel)
#else

    static let groupedListBackground = Color(.underPageBackgroundColor)
    static let reversedTextColor = Color(.textBackgroundColor)
    static let ledOffPlatter = Color(.quaternaryLabelColor)
    static let blockPlatterFill = Color("blockPlatterFill")
    static let blockPlatterStroke = Color(.quaternaryLabelColor)
#endif
}
