//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MagnetometerBlock: View {

    @ObservedObject var vm: MagnetometerSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LoggingSectionStandardized(vm: vm)
            DividerPadded()
            LiveStreamSection(scrollViewGraphID: "MagnetometerStreamGraph", vm: vm)
            
            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .environmentObject(vm)
    }
}
