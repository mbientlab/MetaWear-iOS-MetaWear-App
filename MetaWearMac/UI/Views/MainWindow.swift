//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MainWindow: View {

    @EnvironmentObject var prefs: PreferencesStore
    @EnvironmentObject var ui: UIFactory

    var body: some View {
        NavigationView {
            Sidebar(vc: ui.makeMetaWearScanningSVC())
                .frame(minWidth: .sidebarMinWidth, alignment: .topLeading)

            PlaceholderDeviceConnectionScreen()
        }
        .frame(minWidth: .windowWidthMin, maxWidth: .infinity, minHeight: .windowMinHeight, alignment: .topLeading)
        // Styling
        .lineSpacing(6)
        .fontBody()
        .menuStyle(BorderlessButtonMenuStyle())
        .buttonStyle(BorderlessHoverHighlightButtonStyle())
        .multilineTextAlignment(.leading)
        .environment(\.fontFace, prefs.font)
    }
}
