//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct GyroscopeBlock: View {

    @ObservedObject var vm: GyroSUIVC
    @State private var unitLabelWidth = CGFloat(0)

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            ScaleRow(unitLabelWidth: unitLabelWidth)
            SamplingRow(unitLabelWidth: unitLabelWidth)
            DividerPadded()

            LoggingSectionStandardized(vm: vm)
            DividerPadded()
            LiveStreamSection(scrollViewGraphID: "GyroStreamGraph", vm: vm)

            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .onPreferenceChange(UnitWidthKey.self) { unitLabelWidth = $0 }
        .environmentObject(vm)
    }
}

// MARK: - Settings

extension GyroscopeBlock {

    struct ScaleRow: View {

        @EnvironmentObject private var vm: GyroSUIVC
        var unitLabelWidth: CGFloat

        private var scaleBinding: Binding<GyroscopeGraphRange> {
            Binding { vm.graphRangeSelected }
            set: { vm.userDidSelectGraphScale($0) }

        }

        var body: some View {
#if os(iOS)
            LabeledItem(label: "Scale",
                        content: styledPicker,
                        alignment: .center,
                        contentAlignment: .trailing)
#elseif os(macOS)
            LabeledItem(label: "Scale",
                        content: macOSLabeledPicker,
                        alignment: .center,
                        contentAlignment: .trailing)
#endif
        }

        private var macOSLabeledPicker: some View {
            HStack {
                styledPicker

                Text("°/s")
                    .fontVerySmall()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
                    .matchWidths(to: GyroscopeBlock.UnitWidthKey.self,
                                 width: unitLabelWidth,
                                 alignment: .leading)
            }
        }

        private var styledPicker: some View {
#if os(iOS)
            pickerComponent.frame(maxWidth: .infinity, alignment: .trailing)
#elseif os(macOS)
            pickerComponent.fixedSize()
                .accentColor(.gray)
#endif
        }

        private var pickerComponent: some View {
            Picker(selection: scaleBinding) {
                ForEach(vm.graphRanges) {
                    Text($0.displayName).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.graphRangeSelected.displayName)
#endif
            }
            .contentShape(Rectangle())
            .pickerStyle(.menu)
        }
    }

    struct SamplingRow: View {

        @EnvironmentObject private var vm: GyroSUIVC
        var unitLabelWidth: CGFloat

        private var frequencyBinding: Binding<GyroscopeFrequency> {
            Binding { vm.samplingFrequencySelected }
            set: { vm.userDidSelectSamplingFrequency($0) }
        }

        var body: some View {

#if os(iOS)
            LabeledItem(label: "Sample",
                        content: styledPicker,
                        alignment: .center,
                        contentAlignment: .trailing)
#elseif os(macOS)
            LabeledItem(label: "Sample",
                        content: macosLabeledPicker,
                        alignment: .center,
                        contentAlignment: .trailing)
#endif
        }

        private var macosLabeledPicker: some View {
            HStack {
                styledPicker

                Text("Hz")
                    .fontVerySmall()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
                    .matchWidths(to: GyroscopeBlock.UnitWidthKey.self,
                                 width: unitLabelWidth,
                                 alignment: .leading)
            }
        }

        private var styledPicker: some View {
#if os(iOS)
            pickerComponent.frame(maxWidth: .infinity, alignment: .trailing)
#elseif os(macOS)
            pickerComponent.fixedSize()
                .accentColor(.gray)
#endif
        }

        private var pickerComponent: some View {
            Picker(selection: frequencyBinding) {
                ForEach(vm.samplingFrequencies) {
                    Text($0.frequencyLabel).tag($0)
                }
            } label: {
#if os(iOS)
                Text(vm.samplingFrequencySelected.frequencyLabel + " Hz")
#endif
            }
            .contentShape(Rectangle())
            .pickerStyle(.menu)
        }
    }
}

private extension GyroscopeBlock {

    struct UnitWidthKey: WidthKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
