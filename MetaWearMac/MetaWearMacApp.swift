//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import FeedPlot

@main
struct MetaWearMacApp: App {

    @NSApplicationDelegateAdaptor(AppRoot.self) var root

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(root.preferences)
                .environmentObject(root.ui)
                .onAppear { DispatchQueue.main.async { setupGlobalMetal() } }
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
        .commands { Menus(prefs: root.preferences) }
    }
}
