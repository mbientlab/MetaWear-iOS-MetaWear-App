//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct BatteryBlock: View {

    @ObservedObject var vm: BatterySUIVC

    var body: some View {
        HStack(spacing: .cardVSpacing) {
            
            Text("\(vm.batteryLevelPercentage)%")
                .foregroundColor(color)
                .fontWeight(.medium)
                .fontSmall(weight: .medium)
                .padding(.trailing, 8)

            ProgressView("", value: Float(vm.batteryLevelPercentage), total: Float(100))
                .progressViewStyle(LinearProgressViewStyle(tint: .gray))
                .accessibilityValue(String("\(vm.batteryLevelPercentage)%"))
                .accentColor(color)
                .foregroundColor(color)
                .opacity(vm.batteryLevelPercentage > 40 ? 0.75 : 1)
                .offset(y: -8)
                .accessibilityHidden(true)
            
            Spacer()

            UpdateButton(didTap: vm.userRequestedBatteryLevel, helpAccessibilityLabel: "Refresh Battery Level")
        }
    }

    private var color: Color {
        vm.batteryLevelPercentage > 40 ? Color.primary : Color(.systemPink)
    }
}
