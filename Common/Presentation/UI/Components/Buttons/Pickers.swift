//  Created by Ryan Ferrell on 8/13/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MenuPicker<SelectionValue, Content>: View where SelectionValue : Hashable, Content : View {

    /// Shown on iOS for hit testing, not added on macOS
    var label: String
    @Binding var selection: SelectionValue
    var content: () -> Content

    init(label: String, selection: Binding<SelectionValue>, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        _selection = selection
        self.content = content
    }

    var body: some View {
        #if os(iOS)
        picker
            .fontBody()
        #elseif os(macOS)
        picker
            .fixedSize()
            .accentColor(.gray)
        #endif
    }

    private var picker: some View {
        Picker(selection: $selection,
               label: pickerLabel,
               content: content
        )
        .pickerStyle(MenuPickerStyle())
    }

    var pickerLabel: some View {
        #if os(iOS)
        Text(label).fontBody()
        #else
        EmptyView()
        #endif
    }
}


struct MenuPickerWithUnitsAligned<SelectionValue, Content, Key>: View where SelectionValue : Hashable, Content : View, Key: WidthKey {

    /// Shown on iOS for hit testing, not added on macOS
    var label: String
    @Binding var selection: SelectionValue
    var unitLabel: String
    var unitWidthKey: Key.Type
    var unitLabelWidth: CGFloat
    var unitAlignment: Alignment = .leading
    var content: () -> Content

    init(label: String,
         binding: Binding<SelectionValue>,
         unit: String,
         unitWidthKey: Key.Type,
         unitWidth: CGFloat,
         unitAlignment: Alignment = .leading,
         @ViewBuilder content: @escaping () -> Content) {

        self.label = label
        _selection = binding
        self.unitLabel = unit
        self.unitWidthKey = unitWidthKey
        self.unitLabelWidth = unitWidth
        self.unitAlignment = unitAlignment
        self.content = content
    }

    @ScaledMetric(relativeTo: .body) private var size = MWBody.fontSize

    var body: some View {

        HStack {
#if os(macOS)
            picker
                .fixedSize()
                .accentColor(.gray)
#else
            Spacer()
            picker
                .fontBody()
#endif
            if #available(iOS 15.0, macOS 11.0, *) { // Behavior changed
                SmallUnitLabel(
                    string: unitLabel,
                    equalWidthKey: unitWidthKey,
                    width: unitLabelWidth
                )
            }
        }
    }

    private var picker: some View {
        Picker(selection: $selection,
               label: pickerLabel,
               content: content
        )
            .pickerStyle(MenuPickerStyle())
    }

    var pickerLabel: some View {
#if os(iOS)
        Text(label + " \(unitLabel)").fontBody()
#else
        EmptyView()
        #endif
    }
}

struct MenuPickerWithFixedUnits<SelectionValue, Content>: View where SelectionValue : Hashable, Content : View {

    /// Shown on iOS for hit testing, not added on macOS
    var label: String
    @Binding var selection: SelectionValue
    var unitLabel: String
    var content: () -> Content

    init(label: String,
         binding: Binding<SelectionValue>,
         unit: String,
         @ViewBuilder content: @escaping () -> Content) {

        self.label = label
        _selection = binding
        self.unitLabel = unit
        self.content = content
    }

    var body: some View {
#if os(iOS)
        picker
            .fontBody()
        if #available(iOS 15.0, *) { // Behavior changed
            SmallUnitLabelFixed(unitLabel)
        }
#elseif os(macOS)
        HStack {
            picker
                .fixedSize()
                .accentColor(.gray)

            SmallUnitLabelFixed(unitLabel)
        }
        #endif

    }

    private var picker: some View {
        Picker(selection: $selection,
               label: pickerLabel,
               content: content
        )
        .pickerStyle(MenuPickerStyle())
    }

    var pickerLabel: some View {
        #if os(iOS)
        Text(label + " \(unitLabel)")
        #else
        EmptyView()
        #endif
    }
}
