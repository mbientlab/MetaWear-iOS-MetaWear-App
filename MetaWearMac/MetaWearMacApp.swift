//
//  MetaWearMacApp.swift
//  MetaWearMac
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

@main
struct MetaWearMacApp: App {

    var body: some Scene {
        WindowGroup {
            MainWindow(vc: MetaWearScanningSVC())
        }
    }
}
