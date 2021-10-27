//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

protocol PreferencesPersistence {
    func storeFont(_ face: FontFace)
    func retrieveFont() -> FontFace
    func storeDidOnboard(_ state: Bool)
    func retrieveDidOnboard() -> Bool
}

public class UserDefaultsPersistence {

    private let defaults = UserDefaults.standard

}

extension UserDefaultsPersistence: PreferencesPersistence {

    func storeFont(_ face: FontFace) {
        let dto = FontFaceDTO1(face: face)
        defaults.set(dto.rawValue, forKey: Keys.fontFace.rawValue)
    }

    func retrieveFont() -> FontFace {
        guard let value = defaults.string(forKey: Keys.fontFace.rawValue)
        else { return .system }

        if let dto1 = FontFaceDTO1(rawValue: value) { return dto1.model() }
        else { return .system }
    }

    func storeDidOnboard(_ state: Bool) {
        defaults.set(state, forKey: Keys.didOnboard.rawValue)
    }

    func retrieveDidOnboard() -> Bool {
        defaults.bool(forKey: Keys.didOnboard.rawValue)
    }

    // MARK: - Keys

    private enum Keys: String {
        case fontFace, didOnboard
    }

    // MARK: - DTOs

    private enum FontFaceDTO1: String, CaseIterable {
        case system
        case openDyslexic
        case chalk

        init(face: FontFace) {
            switch face {
                case .system: self = .system
                case .openDyslexic: self = .openDyslexic
                case .chalkboard: self = .chalk
            }
        }

        func model() -> FontFace {
            switch self {
                case .system: return .system
                case .openDyslexic: return .openDyslexic
                case .chalk: return .chalkboard
            }
        }
    }
}
