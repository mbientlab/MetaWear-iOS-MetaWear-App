//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct AmbientLightBlock: View {

    @ObservedObject var vm: AmbientLightSUIVC

    @State private var read = ""
    @State private var enable = ""

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Gain",
                content: gain,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Integration Time",
                content: integration,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Measurement Rate",
                content: measurement,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Illuminance",
                content: stream
            )
        }
    }

    // MARK: - Pickers

    private var gainBinding: Binding<AmbientLightGain> {
        Binding { vm.gainSelected }
        set: { vm.userSetGain($0) }
    }

    private var gain: some View {
        HStack {
            Picker("", selection: gainBinding) {
                ForEach(vm.gainOptions) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)
#if os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif

            Text("x")
                .fontVerySmall()
                .foregroundColor(.secondary)
                .padding(.leading, 5)
        }
    }

    private var integrationBinding: Binding<AmbientLightTR329IntegrationTime> {
        Binding { vm.integrationTimeSelected }
        set: { vm.userSetIntegrationTime($0) }
    }

    private var integration: some View {
        HStack {
            Picker("", selection: integrationBinding) {
                ForEach(vm.integrationTimeOptions) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)
#if os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif

            Text("ms")
                .fontVerySmall()
                .foregroundColor(.secondary)
                .padding(.leading, 5)
        }
    }

    private var measurementBinding: Binding<AmbientLightTR329MeasurementRate> {
        Binding { vm.measurementRateSelected }
        set: { vm.userSetMeasurementRate($0) }
    }

    private var measurement: some View {
        HStack {
            Picker("", selection: measurementBinding) {
                ForEach(vm.measurementRateOptions) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)
#if os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif

            Text("ms")
                .fontVerySmall()
                .foregroundColor(.secondary)
                .padding(.leading, 5)
        }
    }

    // MARK: - Streaming

    private var stream: some View {
        HStack {
            Text(vm.illuminanceString)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text("lux")
                .fontVerySmall()
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
                .opacity(vm.illuminanceString.isEmpty ? 0 : 1)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Stream") {
                if vm.isStreaming { vm.userRequestedStreamStop() }
                else { vm.userRequestedStreamStart() }
            }
        }
    }
}
