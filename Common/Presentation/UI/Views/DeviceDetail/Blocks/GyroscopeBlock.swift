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
            LabeledItem(
                label: "Frequency",
                content: picker,
                contentAlignment: .trailing
            )
        }
        
        private var picker: some View {
            MenuPickerWithUnitsAligned(
                label: vm.graphRangeSelected.displayName,
                binding: scaleBinding,
                unit: "°/s",
                unitWidthKey: GyroscopeBlock.UnitWidthKey.self,
                unitWidth: unitLabelWidth
            ) {
                ForEach(vm.graphRanges) {
                    Text($0.displayName).tag($0)
                }
            }
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
            LabeledItem(
                label: "Sample",
                content: picker,
                contentAlignment: .trailing
            )
        }
        
        private var picker: some View {
            MenuPickerWithUnitsAligned(
                label: vm.samplingFrequencySelected.frequencyLabel,
                binding: frequencyBinding,
                unit: "Hz",
                unitWidthKey: GyroscopeBlock.UnitWidthKey.self,
                unitWidth: unitLabelWidth
            ) {
                ForEach(vm.samplingFrequencies) {
                    Text($0.frequencyLabel).tag($0)
                }
            }
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

