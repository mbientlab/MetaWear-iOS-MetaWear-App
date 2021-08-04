//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct BatteryBlock: View {

    @ObservedObject var vm: MWDetailBatterySVC

    var body: some View {
        HStack(spacing: .cardVSpacing) {
            Text("\(vm.batteryLevelPercentage)%")
                .foregroundColor(color)
                .fontWeight(.medium)
                .font(.subheadline)
                .padding(.trailing, 8)

            ProgressView("", value: Float(vm.batteryLevelPercentage), total: Float(100))
                .progressViewStyle(.linear)
                .accessibilityValue(String("\(vm.batteryLevelPercentage)%"))
                .accentColor(color)
                .foregroundColor(color)
                .offset(y: -8)
            
            Spacer()

            UpdateButton(didTap: vm.userRequestedBatteryLevel, helpAccessibilityLabel: "Check Battery")
        }
    }

    var color: Color {
        vm.batteryLevelPercentage > 40 ? Color.primary : Color(.systemPink)
    }
}
