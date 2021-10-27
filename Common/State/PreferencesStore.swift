//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import Combine


public class PreferencesStore: ObservableObject, ColorsetProvider {

    @Published private(set) var didOnboard: Bool
    @Published private(set) var font: FontFace

    private(set) public var colorset: CurrentValueSubject<Colorset, Never>
    private var diffs: Set<AnyCancellable> = []
    private let persistence: PreferencesPersistence

    init(persistence: PreferencesPersistence) {
        self.persistence = persistence
        self.font = persistence.retrieveFont()
        self.didOnboard = persistence.retrieveDidOnboard()
        self.colorset = .init(.bright)
        colorset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &diffs)
    }

    func setFont(face: FontFace) {
        font = face
        persistence.storeFont(face)
    }

    func setDidOnboard(_ state: Bool) {
        self.didOnboard = state
        persistence.storeDidOnboard(state)
    }
}

// MARK: - Colorset

public protocol ColorsetProvider {
    var colorset: CurrentValueSubject<Colorset, Never> { get }
}


public enum Colorset: String, CaseIterable, Identifiable {
    case bright = "Bright"

    public var id: String { rawValue }
}

import SwiftUI

public extension Colorset {

    var colors: [Color] {
        switch self {
            case .bright: return [.plotBlue, .plotGold, .plotPink, .plotGray]
        }
    }

    var hex: [String] {
        switch self {
            case .bright: return ["#FD127C", "#04CBF4", "#FBBE69", "#758374"]
        }
    }
}
