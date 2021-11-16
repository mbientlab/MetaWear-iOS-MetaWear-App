//
//  AdaptiveFont.swift
//  AdaptiveFont
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public enum FontFace: Int, Hashable, CaseIterable, Identifiable, Codable {
    case system
    case openDyslexic
    case chalkboard

    public var font: String {
        switch self {
            case .system: return ""
            case .openDyslexic: return "OpenDyslexicMono-Regular"
            case .chalkboard: return "ChalkboardSE-Regular"
        }
    }

    public var boldFont: String {
        switch self {
            case .system: return ""
            case .openDyslexic: return "OpenDyslexicThree-Bold"
            case .chalkboard: return "ChalkboardSE-Bold"
        }
    }

    public var monospaceFont: String {
        switch self {
            case .system: return ""
            case .openDyslexic: return "OpenDyslexicMono-Regular"
            case .chalkboard: return "ChalkboardSE-Regular"
        }
    }

    public var name: String {
        switch self {
            case .system: return "System default"
            case .openDyslexic: return "OpenDyslexic 3"
            case .chalkboard: return "Chalkboard"
        }
    }

    public var id: Int { rawValue }

}

