//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct IdentifiersBlock: View {

    @ObservedObject var vm: MWDetailIdentifiersSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "Manufacturer",
                content: manufacturer
            )

            LabeledItem(
                label: "Model #",
                content: model
            )

            LabeledItem(
                label: "Serial #",
                content: serial
            )

            LabeledItem(
                label: "Hardware Rev",
                content: hardware
            )
        }
    }

    var manufacturer: some View {
        Text(vm.manufacturer)
    }

    var model: some View {
        Text(vm.manufacturer)
    }

    var serial: some View {
        Text(vm.manufacturer)
    }

    var hardware: some View {
        Text(vm.manufacturer)
    }
}
