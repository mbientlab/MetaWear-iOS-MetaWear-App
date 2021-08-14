//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct TemperatureBlock: View {

    @ObservedObject var vm: TemperatureSUIVC

    @State private var read = ""
    @State private var enable = ""

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LabeledItem(
                label: "Reported",
                content: temp
            )

            LabeledItem(
                label: "Type",
                content: channelType
            )

            LabeledItem(
                label: "Channel",
                content: channel
            )

            if vm.showPinDetail { pins }
        }
    }

    private var channelBinding: Binding<Int> {
        Binding { vm.selectedChannelIndex }
        set: { vm.selectChannel(at: $0) }

    }

    private var channel: some View {
        Picker(selection: channelBinding, label: EmptyView()) {
            ForEach(vm.channelsIndexed, id: \.index) {
                Text($0.label).tag($0.index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var temp: some View {
        HStack {
            Text(vm.temperature)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer()

            UpdateButton(didTap: vm.readTemperature,
                         helpAccessibilityLabel: "Read Temperature")
        }
    }

    private var channelType: some View {
        Text(vm.selectedChannelType)
    }


    private var pins: some View {
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
