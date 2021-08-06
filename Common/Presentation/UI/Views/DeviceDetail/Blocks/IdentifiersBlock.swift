//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct IdentifiersBlock: View {

    @ObservedObject var vm: MWDetailIdentifiersSVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "OEM",
                content: manufacturer
            )

            LabeledItem(
                label: "Model",
                content: model
            )

            LabeledItem(
                label: "Serial",
                content: serial
            )

            LabeledItem(
                label: "Hardware",
                content: hardware
            )
        }
        .animation(.none)
    }

    private var manufacturer: some View {
        Text(vm.manufacturer)
    }

    private var model: some View {
        Text(vm.modelNumber)
    }

    private var serial: some View {
        Text(vm.serialNumber)
    }

    private var hardware: some View {
        Text(vm.harwareRevision)
    }
}
