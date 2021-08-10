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
                .environmentObject(vc)

            PlaceholderDeviceConnectionScreen()

        }
        .onAppear { vc.startScanning() }
        .frame(minWidth: .windowWidthMin, minHeight: .windowMinHeight)
        .environmentObject(prefs)

        // Styling
        .lineSpacing(6)
        .fontBody()
        .menuStyle(.borderlessButton)
        .buttonStyle(BorderlessHoverHighlightButtonStyle())
        .multilineTextAlignment(.leading)
        .environment(\.fontFace, prefs.font)
    }
}
