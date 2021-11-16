//  Created by Ryan Ferrell on 8/13/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct Toolbar: ToolbarContent {

    @ObservedObject var vm: DetailHeaderSUIVC

    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
            ConnectionToolbarButton(vm: vm)
                .accentColor(.accentColor)
                .foregroundColor(.accentColor)
        }
        #elseif os(macOS)
        ToolbarItemGroup(placement: .status) {
            ConnectionToolbarButton(vm: vm)
        }
        #endif
    }
}
