//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ResetBlock: View {

    @ObservedObject var vm: MWResetSVC

    var body: some View {
        HStack {
            Spacer()
            reset
            Spacer()
            sleep
            Spacer()
        }
    }

    var reset: some View {
        Menu("Reset") {
            Button("Soft") { vm.userRequestedSoftReset() }
            Button("Factory") { vm.userRequestedFactoryReset() }
        }
    }

    var sleep: some View {
        Button("Sleep") { vm.userRequestedSleep() }
    }
}
