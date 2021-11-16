//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct iBeaconBlock: View {

    @ObservedObject var vm: iBeaconSUIVC

    var body: some View {
        HStack {
            Spacer()
            Button(vm.iBeaconIsOn ? "Stop" : "Start") {
                if vm.iBeaconIsOn {
                    vm.userRequestedStopIBeacon()
                } else {
                    vm.userRequestedStartIBeacon()
                }
            }
            Spacer()
        }
    }
}
