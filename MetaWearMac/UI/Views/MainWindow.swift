//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MainWindow: View {

    @ObservedObject var prefs: PreferencesStore
    @StateObject var vc: MetaWearScanningSVC

    var body: some View {
        NavigationView {
            Sidebar()
                .frame(minWidth: .sidebarMinWidth, alignment: .topLeading)
                .environmentObject(vc)

            PlaceholderDeviceConnectionScreen()
        }
        .onAppear { vc.startScanning() }
        .frame(minWidth: .windowWidthMin, maxWidth: .infinity, minHeight: .windowMinHeight, alignment: .topLeading)
        .environmentObject(prefs)

        // Styling
        .lineSpacing(6)
        .fontBody()
        .menuStyle(BorderlessButtonMenuStyle())
        .buttonStyle(BorderlessHoverHighlightButtonStyle())
        .multilineTextAlignment(.leading)
        .environment(\.fontFace, prefs.font)
    }
}
