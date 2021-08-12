//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct BarometerBlock: View {

    @ObservedObject var vm: BarometerSUIVC

    @State private var unitWidth = CGFloat(0)
    @State private var read = ""
    @State private var enable = ""

    var body: some View {
        VStack(spacing: .cardVSpacing) {

            LabeledItem(
                label: "Oversampling",
                content: oversampling,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Averaging",
                content: averaging,
                contentAlignment: .trailing
            )

            LabeledItem(
                label: "Standby Time",
                content: standbyTime,
                contentAlignment: .trailing
            )

            DividerPadded()

            LabeledItem(
                label: "Altitude",
                content: stream
            )
        }
        .onPreferenceChange(UnitWidthKey.self) { unitWidth = $0 }
    }

    // MARK: - Pickers

    private var oversamplingBinding: Binding<BarometerOversampling> {
        Binding { vm.oversamplingSelected }
        set: { vm.userSetOversampling($0) }
    }

    private var oversampling: some View {
            Picker("", selection: oversamplingBinding) {
                ForEach(vm.oversamplingOptions) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.menu)
#if os(macOS)
            .fixedSize()
            .accentColor(.gray)
#endif
    }

    private var iirFilterBinding: Binding<BarometerIIRFilter> {
        Binding { vm.iirFilterSelected }
        set: { vm.userSetIIRFilter($0) }
    }

    private var averaging: some View {
        HStack {
            Picker("", selection: iirFilterBinding) {
                ForEach(vm.iirTimeOptions) {
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
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
                .matchWidths(to: UnitWidthKey.self, width: unitWidth, alignment: .leading)
        }
    }

    private var standbyTimeBinding: Binding<BarometerStandbyTime> {
        Binding { vm.standbyTimeSelected }
        set: { vm.userSetStandbyTime($0) }
    }

    private var standbyTime: some View {
        HStack {
            Picker("", selection: standbyTimeBinding) {
                ForEach(vm.standbyTimeOptions) {
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
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
                .matchWidths(to: UnitWidthKey.self, width: unitWidth, alignment: .leading)
        }
    }

    // MARK: - Streaming

    private var stream: some View {
        HStack {
            Text(vm.altitudeString)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text("m")
                .fontVerySmall()
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
                .opacity(vm.altitudeString.isEmpty ? 0 : 1)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Stream") {
                if vm.isStreaming { vm.userRequestedStreamStop() }
                else { vm.userRequestedStreamStart() }
            }
        }
    }
}

private extension BarometerBlock {

    struct UnitWidthKey: WidthKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

