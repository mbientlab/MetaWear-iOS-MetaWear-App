//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import FeedPlot

@main
struct MetaWearMacApp: App {

    @StateObject var store = AppStore()

    var body: some Scene {
        WindowGroup {
            MainWindow(prefs: store.preferences,
                       vc: store.ui.makeMetaWearScanningSVC())
                .environmentObject(store)
                .onAppear { DispatchQueue.main.async { setupGlobalMetal() } }
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
        .commands { Menus(prefs: store.preferences) }
    }
}
