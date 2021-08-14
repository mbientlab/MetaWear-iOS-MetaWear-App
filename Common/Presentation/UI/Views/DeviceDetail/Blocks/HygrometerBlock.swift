//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct HygrometerBlock: View {

    @ObservedObject var vm: HumiditySUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Oversampling",
                content: oversampling
            )

            LabeledItem(
                label: "Live",
                content: button
            )
        }
    }

    private var oversampling: some View {
        HStack {
            if vm.isOversampling {
                Image(systemName: "checkmark")
                    .fontBody(weight: .bold)

            } else {
                Text("Suspended")
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            MenuPicker(label: vm.oversamplingSelected.displayName,
                                selection: oversamplingOptions) {
                ForEach(vm.oversamplingOptions) {
                    Text(String($0.displayName)).tag($0)
                }
            }
        }
    }

    private var oversamplingOptions: Binding<HumidityOversampling> {
        Binding { vm.oversamplingSelected } set: {
            vm.userSetHumidityOversampling($0)
        }
    }

    private var button: some View {
        HStack {
            Text(vm.humidityReadout)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Stream") {
                if vm.isStreaming { vm.userRequestedStreamingStop() }
                else { vm.userRequestedStreamingStart() }
            }
        }
    }
}
