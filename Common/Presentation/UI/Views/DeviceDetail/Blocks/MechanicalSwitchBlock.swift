//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MechanicalSwitchBlock: View {

    @ObservedObject var vm: MWMechanicalSwitchSVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "State",
                content: button
            )
        }
    }

    private var button: some View {
        HStack {
            Text(vm.switchState)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(vm.isMonitoring ? "Stop" : "Stream") {
                if vm.isMonitoring { vm.userStoppedMonitoringSwitch() }
                else { vm.userStartedMonitoringSwitch() }
            }
        }
    }
}
