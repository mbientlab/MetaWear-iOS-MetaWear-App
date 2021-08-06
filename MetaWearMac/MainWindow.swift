//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MainWindow: View {

    @StateObject var vc: MetaWearScanningSVC

    var body: some View {
        NavigationView {
            Sidebar().environmentObject(vc)
            Color.clear
        }
        .multilineTextAlignment(.leading)
    }
}
