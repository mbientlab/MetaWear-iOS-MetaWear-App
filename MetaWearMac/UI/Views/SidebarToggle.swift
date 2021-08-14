//  Created by Ryan on 8/15/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SidebarToggle: View {

    var body: some View {
        Button {
            NSApp.keyWindow?.firstResponder?
                .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        } label: { Image(systemName: "sidebar.left") }
        .help("Toggle sidebar")
        .buttonStyle(DefaultButtonStyle())
    }
}
