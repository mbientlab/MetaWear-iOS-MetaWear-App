//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct iPadGridLayout<Column: View, GridItems: View>: View {

    var width: CGFloat
    var identity: Column
    var sensors: GridItems

    var body: some View {
        LazyVGrid(columns: gridColumns,
                  alignment: .leading,
                  spacing: .cardGridSpacing) {

            Section {
                identity
            }.accessibilityLabel("Device Identity and Management")

            Section {
                sensors
            } .accessibilityLabel("Device Sensor Readouts")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 10)
    }

    let gridColumns: [GridItem] = [
        .init(.adaptive(minimum: .detailBlockWidth, maximum: .detailBlockWidth),
              spacing: .cardGridSpacing,
              alignment: .topLeading)
    ]
}
