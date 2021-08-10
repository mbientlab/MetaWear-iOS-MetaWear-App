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
            VStack(alignment: .leading, spacing: .cardGridSpacing) {
                leftColumn
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .frame(width: .detailBlockWidth, alignment: .topLeading)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Device Identity and Management")


            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: .cardGridSpacing) {
                rightGridItems
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .animation(.easeOut(duration: 0.15))
            .padding(.top, .cardGridSpacing / 2)
            .accessibilityLabel("Device Sensor Readouts")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 10)
    }

    let gridColumns: [GridItem] = [
        .init(.adaptive(minimum: .detailBlockWidth, maximum: .detailBlockWidth),
              spacing: 25,
              alignment: .topLeading)
    ]
}
