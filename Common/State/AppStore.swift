//
//  AppStore.swift
//  AppStore
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public class AppStore: ObservableObject {

    public init() {
        let environment = UIEnvironment.swiftUIMinimumV2
        self.ui = DevelopmentUIFactory(environment: environment)
        self.preferences = PreferencesStore(persistence: UserDefaultsPersistence())
    }

    public let ui: UIFactory
    public let preferences: PreferencesStore

}
