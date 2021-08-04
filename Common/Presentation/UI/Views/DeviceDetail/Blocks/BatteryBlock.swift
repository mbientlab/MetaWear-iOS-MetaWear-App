//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct BatteryBlock: View {

    @ObservedObject var vm: MWDetailBatterySVC

    var body: some View {
        VStack {
            ProgressView("Charge",
                         value: Float(vm.batteryLevelPercentage),
                         total: Float(100))
                .progressViewStyle(.circular)
                .foregroundColor(vm.batteryLevelPercentage > 40 ? Color(.systemGreen) : Color(.systemPink))

            Spacer()

            Button("Update") { vm.userRequestedBatteryLevel() }
        }
    }
}
