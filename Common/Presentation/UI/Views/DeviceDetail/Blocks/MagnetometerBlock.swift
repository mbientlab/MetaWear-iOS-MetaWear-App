//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MagnetometerBlock: View {

    @ObservedObject var vm: MagnetometerSUIVC

    var body: some View {
        TwoSectionNoOptionsLayout(
            leftColumn: LoggingSectionStandardized(vm: vm),
            rightColumn: LiveStreamSection(scrollViewGraphID: "MagnetometerStreamGraph", vm: vm)
        )
        .environmentObject(vm)
    }
}
