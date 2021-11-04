//
//  AppStore.swift
//  AppStore
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class AppRoot: NSObject, ObservableObject {

    override public init() {
        self.ui = UIFactory()
        self.preferences = PreferencesStore(persistence: UserDefaultsPersistence())
        super.init()
    }

    public let ui: UIFactory
    public let preferences: PreferencesStore

}

#if os(macOS)
extension AppRoot: NSApplicationDelegate {}
#else
extension AppRoot {}
#endif
