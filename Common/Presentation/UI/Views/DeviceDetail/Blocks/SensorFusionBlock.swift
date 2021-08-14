//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SensorFusionBlock: View {

    @ObservedObject var vm: SensorFusionSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            ScaleRow()
            OutputType()
            DividerPadded()

            LoggingSectionStandardized(vm: vm)
            DividerPadded()
            LiveStreamSection(scrollViewGraphID: "SensorFusionStreamGraph", vm: vm)

            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .environmentObject(vm)
    }
}

// MARK: - Settings

extension SensorFusionBlock {

    struct ScaleRow: View {

        @EnvironmentObject private var vm: SensorFusionSUIVC

        private var binding: Binding<SensorFusionMode> {
            Binding { vm.selectedFusionMode }
            set: { vm.userSetFusionMode($0) }

        }

        var body: some View {
            LabeledItem(label: "Mode",
                        content: picker,
                        alignment: .center,
                        contentAlignment: .trailing)
        }

        private var picker: some View {
            MenuPicker(label: vm.selectedFusionMode.displayName,
                       selection: binding) {
                ForEach(vm.fusionModes) {
                    Text($0.displayName).tag($0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    struct OutputType: View {

        @EnvironmentObject private var vm: SensorFusionSUIVC

        private var binding: Binding<SensorFusionOutputType> {
            Binding { vm.selectedOutputType }
            set: { vm.userSetOutputType($0) }
        }

        var body: some View {
            LabeledItem(label: "Output",
                        content: picker,
                        alignment: .center,
                        contentAlignment: .trailing)
        }

        private var picker: some View {
            MenuPicker(label: vm.selectedOutputType.fullName,
                       selection: binding) {
                ForEach(vm.outputTypes) {
                    Text($0.fullName).tag($0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
