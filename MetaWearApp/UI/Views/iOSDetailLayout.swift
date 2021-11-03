//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct iOSDeviceDetailLayout: View {
    var chain: Namespace.ID
    var details: Namespace.ID
    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.fontFace) private var fontFace

    @State private var contentSize: CGSize = .zero
    @Environment(\.contentHeight) private var height

    var body: some View {
        ScrollView(.vertical) {
            layoutByWidth
                .padding(.bottom, 20)
        }
        .background(readDimensions)
        .ignoresSafeArea(.container, edges: [.bottom])
        .background(Color.groupedListBackground.ignoresSafeArea())
        .environment(\.contentHeight, contentSize.height)
        .coordinateSpace(name: CoordinateSpace.Names.DetailScrollView.rawValue )
    }

    @ViewBuilder var layoutByWidth: some View {
        if contentSize.width < 1000 { // iPhone or narrow screen
            VStack(spacing: .cardGridSpacing) {
                ForEach(vc.sortedVisibleGroups) { group in
                    BlockBuilder(group: group, namespace: details)
                }
            }
            .padding(.top, 10)
            .animation(.easeOut(duration: 0.15))
            .frame(maxWidth: .infinity, alignment: .center)

        } else {
            GridLayout(details: details, alignment: .center, forInfoPanels: true)
                .padding(.bottom, 20)
                .padding(.top, fontFace == .openDyslexic ? 28 : 18)
                .padding(.bottom, .cardGridSpacing)

            DividerPadded().padding(.horizontal)

            GridLayout(details: details, alignment: .top, forInfoPanels: false)
                .padding(.bottom, 20)
                .padding(.top, fontFace == .openDyslexic ? 28 : 18)
        }
    }

    var readDimensions: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { contentSize = geo.size }
                .onChange(of: geo.size) { contentSize = $0 }
        }
    }
}
