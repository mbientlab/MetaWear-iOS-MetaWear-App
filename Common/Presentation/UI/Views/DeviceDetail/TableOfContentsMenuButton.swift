//
//  TableOfContentsMenuButton.swift
//  TableOfContentsMenuButton
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct TableOfContentsMenuButton: View {

    @EnvironmentObject private var vc: MWDeviceDetailScreenSVC
    @Environment(\.scrollProxy) private var scroller

    var body: some View {
        Menu {
            Button("Device Name") { scroller?.scrollTo(DetailGroup.headerInfoAndState.id, anchor: .top) }
            ForEach(vc.sortedVisibleGroups) { group in
                Button(group.title) { scroller?.scrollTo(group.id, anchor: .bottom) }
            }
        } label: {
            Image(systemName: SFSymbol.shortcutMenu.rawValue)
                .accessibilityHidden(true)
        }
        .help("MetaWear Capabilities")
        .accessibility(label: Text("MetaWear Capabilities Shortcut Menu"))
        .accessibility(hint: Text("Scrolls to the chosen capability"))
        .keyboardShortcut("\\")
    }
}
