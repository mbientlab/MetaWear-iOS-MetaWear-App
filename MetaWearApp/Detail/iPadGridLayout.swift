//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct iPadGridLayout<Column: View, GridItems: View>: View {

    var width: CGFloat
    var leftColumn: Column
    var rightGridItems: GridItems

    var body: some View {
        HStack(alignment: .top) {

            Spacer()

            VStack(alignment: .leading, spacing: .cardGridSpacing) {
                leftColumn
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Device Identity and Management")
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .frame(width: .detailBlockWidth, alignment: .topLeading)

                Spacer(minLength: 0)

            Group {
                if width > singleColumnWidth * 3 {
                    rightMultipleColumns
                } else {
                    rightSingleColumn
                }
            }
            .animation(.easeOut(duration: 0.15))
            .padding(.top, .cardGridSpacing / 2)
            .accessibilityLabel("Device Sensor Readouts")

            Spacer()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 10)
    }

    var rightMultipleColumns: some View {
        LazyVGrid(columns: gridColumns, alignment: .center, spacing: .cardGridSpacing) {
            rightGridItems
        }
        .frame(maxWidth: singleColumnWidth * 2, maxHeight: .infinity, alignment: .center)
    }

    var rightSingleColumn: some View {
        LazyVStack(alignment: .center, spacing: .cardGridSpacing) {
            rightGridItems
        }
        .frame(maxWidth: singleColumnWidth, maxHeight: .infinity, alignment: .center)
    }

    let singleColumnWidth = .detailBlockWidth + (.cardGridSpacing * 2)

    let gridColumns: [GridItem] = [
        .init(.adaptive(minimum: .detailBlockWidth, maximum: .detailBlockWidth),
              spacing: 25,
              alignment: .topLeading)
    ]
}
