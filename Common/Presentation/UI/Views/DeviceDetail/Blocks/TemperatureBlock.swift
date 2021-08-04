//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct TemperatureBlock: View {

    @ObservedObject var vm: MWTemperatureSVC

    var body: some View {
        VStack {
            LabeledItem(
                label: "Scale",
                content: temp
            )

            LabeledItem(
                label: "Channel",
                content: channel
            )

            LabeledItem(
                label: "Type",
                content: channelType
            )

        }
    }

    var channelBinding: Binding<Int> {
        Binding { vm.selectedChannelIndex }
        set: { vm.selectChannel(at: $0) }

    }
    var channel: some View {
        Picker("", selection: channelBinding) {
            ForEach(vm.channelsIndexed, id: \.index) {
                Text($0.label).tag($0.index)
            }
        }
    }

    var temp: some View {
        HStack {
            Text(vm.temperature)
            UpdateButton(didTap: vm.readTemperature,
                         helpAccessibilityLabel: "Read Temperature")
        }
    }

    var channelType: some View {
        Text(vm.selectedChannelType)
    }

    @State private var read = ""
    @State private var enable = ""
    var pins: some View {
        HStack {
            TextField("Read", text: $read) { _ in } onCommit: {
                vm.setReadPin(read)
            }

            TextField("Enable", text: $enable) { _ in } onCommit: {
                vm.setEnablePin(enable)
            }
        }
        .onAppear { read = vm.readPin }
        .onChange(of: vm.readPin) { read = $0 }
        .onAppear { enable = vm.enablePin }
        .onChange(of: vm.enablePin) { enable = $0 }
    }
}
