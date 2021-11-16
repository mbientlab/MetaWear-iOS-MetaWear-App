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
            reset.controlSize(.regular)
            #else
            reset
            #endif

            Spacer()

            sleep

            Spacer()
        }
    }

    private var reset: some View {
        Menu("Reset") {
            Button("Soft") { vm.userRequestedSoftReset() }
            Button("Factory") { vm.userRequestedFactoryReset() }
        }
        .fixedSize()
    }

    private var sleep: some View {
        Button("Sleep") { vm.userRequestedSleep() }

    }
}
