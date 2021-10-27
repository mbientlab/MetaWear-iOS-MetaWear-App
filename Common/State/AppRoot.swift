//
//  AppStore.swift
//  AppStore
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import CoreBluetoothMock

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
extension AppRoot: NSApplicationDelegate {

    public func applicationWillFinishLaunching(_ notification: Notification) {
        launchMockBluetooth()
    }

}
#else
extension AppRoot {

    public func applicationWillFinishLaunching(_ application: UIApplication, options: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        launchMockBluetooth()
    }
}
#endif


extension AppRoot {

    func launchMockBluetooth() {
#if DEBUG
        if CommandLine.arguments.contains("mocking-enabled") {
            launchMockBluetooth()
        }
#endif
    }
}
