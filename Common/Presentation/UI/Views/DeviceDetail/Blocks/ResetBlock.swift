//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ResetBlock: View {

    @ObservedObject var vm: ResetSUIVC

    var body: some View {
        HStack {
            Spacer()

            #if os(macOS)
            reset_macOS
            #else
            reset_iOS
            #endif

            Spacer()
            sleep
            Spacer()
        }
    }

    private var reset_iOS: some View {
        Menu("Reset") {
            Button("Soft") { vm.userRequestedSoftReset() }
            Button("Factory") { vm.userRequestedFactoryReset() }
        }
        .fixedSize()
    }

    @ViewBuilder private var reset_macOS: some View {
        Button("Soft Reset") { vm.userRequestedSoftReset() }
        Spacer()
        Button("Factory Wipe") { vm.userRequestedFactoryReset() }
    }

    private var sleep: some View {
        Button("Sleep") { vm.userRequestedSleep() }

    }
}
