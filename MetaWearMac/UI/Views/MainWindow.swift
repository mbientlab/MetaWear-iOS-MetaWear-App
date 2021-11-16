//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MainWindow: View {

    @EnvironmentObject private var prefs: PreferencesStore
    @EnvironmentObject private var ui: UIFactory
    @Environment(\.colorScheme) private var scheme

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
        .onChange(of: scheme) { _ in prefs.refreshGraphColorsetsOnColorSchemeChange() }
    }
}
