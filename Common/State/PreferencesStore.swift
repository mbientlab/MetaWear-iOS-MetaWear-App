//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public class PreferencesStore: ObservableObject {

    @Published private(set) var font: FontFace = .system

    init(persistence: PreferencesPersistence) {
        self.persistence = persistence
    }

    private let persistence: PreferencesPersistence

    func setFont(face: FontFace) {
        font = face
        persistence.storeFont(face)
    }
}
