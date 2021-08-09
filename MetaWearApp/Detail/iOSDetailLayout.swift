//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct iOSDeviceDetailLayout: View {
    var chain: Namespace.ID
    var details: Namespace.ID
    @EnvironmentObject private var vc: MWDeviceDetailScreenSVC
    @Environment(\.fontFace) private var fontFace

    @State private var width: CGFloat = 999

    @ViewBuilder var body: some View {
        Group {
            if width < 1000 { // iPad vertical or iPhone
                VStack(spacing: .cardGridSpacing) {

                    Header()

                    ForEach(vc.sortedVisibleGroups) { group in
                        CardBuilder(group: group, namespace: details)
                    }
                }
                .padding(.top, 10)
                .animation(.easeOut(duration: 0.15))
                .frame(maxWidth: .infinity, alignment: .center)

            } else {
                iPadGridLayout(
                    width: width,
                    leftColumn: LeftColumn(details: details),
                    rightGridItems: RightColumns(details: details)
                )
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background(readWidth)
    }

    var readWidth: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { width = geo.size.width }
                .onChange(of: geo.size.width) { self.width = $0 }
        }
    }
}

