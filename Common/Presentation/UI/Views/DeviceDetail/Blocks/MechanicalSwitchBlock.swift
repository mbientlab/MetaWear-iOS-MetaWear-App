//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MechanicalSwitchBlock: View {

    @ObservedObject var vm: MWMechanicalSwitchSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "State",
                content: button
            )
        }
    }

    var button: some View {
        HStack {
            Button(vm.isMonitoring ? "Stop" : "Monitor") {
                if vm.isMonitoring { vm.userStoppedMonitoringSwitch() }
                else { vm.userStartedMonitoringSwitch() }
            }

            Spacer()

            Text(vm.switchState)
        }
    }
}
