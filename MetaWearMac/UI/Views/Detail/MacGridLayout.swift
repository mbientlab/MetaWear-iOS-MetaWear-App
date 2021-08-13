//
//  MacGridLayout.swift
//  MacGridLayout
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MacGridLayout<Column: View, GridItems: View>: View {

    var leftColumn: Column
    var rightGridItems: GridItems

    var body: some View {
        HStack(alignment: .top) {
            layoutLeftStaticColumn
            layoutRightDynamicColumn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 10)
    }

    // MARK: - Static

    var layoutLeftStaticColumn: some View {
        VStack(alignment: .leading, spacing: .cardGridSpacing) {
            leftColumn
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .frame(width: .detailBlockWidth, alignment: .topLeading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Device Identity and Management")
    }

    // MARK: - Dynamic

    var layoutRightDynamicColumn: some View {
        LazyVGrid(columns: gridColumns,
                  alignment: .leading,
                  spacing: .cardGridSpacing) {

            rightGridItems
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        .padding(.top, .cardGridSpacing / 2)
        .accessibilityLabel("Device Sensor Readouts")
    }

    let gridColumns: [GridItem] = [
        // Not specifying maximum will result in a "trailing" second column
        .init(.adaptive(minimum: .detailBlockWidth, maximum: .detailBlockWidth),
              spacing: .cardGridSpacing,
              alignment: .topLeading)
    ]
}
