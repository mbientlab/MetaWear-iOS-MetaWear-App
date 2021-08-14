//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import Combine

public protocol ColorsetProvider {
    var colorset: CurrentValueSubject<Colorset, Never> { get }
}

public class PreferencesStore: ObservableObject, ColorsetProvider {


    @Published private(set) var font: FontFace = .system
    private(set) public var colorset: CurrentValueSubject<Colorset, Never>
    private var diffs: Set<AnyCancellable> = []

    init(persistence: PreferencesPersistence) {
        self.persistence = persistence
        self.colorset = .init(.bright)
        colorset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &diffs)
    }

    private let persistence: PreferencesPersistence

    func setFont(face: FontFace) {
        font = face
        persistence.storeFont(face)
    }
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
