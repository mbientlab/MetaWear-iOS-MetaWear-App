//
//  MacGridLayout.swift
//  MacGridLayout
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MacGridLayout<Column: View, GridItems: View>: View {

    var identitySection: Column
    var sensors: GridItems

    var body: some View {
        LazyVGrid(columns: gridColumns,
                  alignment: .leading,
                  spacing: .cardGridSpacing) {

            Section {
                identitySection
            }.accessibilityLabel("Device Identity and Management")

            Section {
                sensors
            } .accessibilityLabel("Device Sensor Readouts")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 10)
    }

    let gridColumns: [GridItem] = [
        // Not specifying maximum will result in a "trailing" second column
        .init(.adaptive(minimum: .detailBlockWidth, maximum: .detailBlockWidth),
              spacing: .cardGridSpacing,
              alignment: .topLeading)
    ]
}
