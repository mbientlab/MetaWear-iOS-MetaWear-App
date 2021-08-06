//
//  Color.swift
//  Color
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

extension Color {
    static let signalObtained = Color(.systemBlue)

#if os(iOS)
    static let toastPillBackground = Color(.systemFill)
    static let groupedListBackground = Color(.systemGroupedBackground)
    static let reversedTextColor = Color(.systemBackground)
    static let ledOffPlatter = Color(.systemGray3)
    static let blockPlatterFill = Color(.secondarySystemGroupedBackground)
    static let blockPlatterStroke = Color(.quaternaryLabel)
#else
    static let toastPillBackground = Color(.quaternaryLabelColor)
    static let groupedListBackground = Color(.underPageBackgroundColor)
    static let reversedTextColor = Color(.textBackgroundColor)
    static let ledOffPlatter = Color(.quaternaryLabelColor)
    static let blockPlatterFill = Color(.textBackgroundColor)
    static let blockPlatterStroke = Color(.quaternaryLabelColor)
#endif
}

