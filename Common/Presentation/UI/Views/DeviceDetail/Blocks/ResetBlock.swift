//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ResetBlock: View {

    @ObservedObject var vm: MWResetSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "Settings",
                content: reset
            )

            LabeledItem(
                label: "Power",
                content: sleep
            )
        }
    }

    var reset: some View {
        HStack {
            Button("Soft Rest") { vm.userRequestedSoftReset() }
            Button("Restore Factory Defaults") { vm.userRequestedFactoryReset() }
        }
    }

    var sleep: some View {
        Button("Sleep") { vm.userRequestedSleep() }
    }
}
