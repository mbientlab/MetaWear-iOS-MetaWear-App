//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

struct DeviceDetailScreen: View {

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.colorScheme) private var colorScheme

    var chain: Namespace.ID // accessibility
    @Namespace private var details // accessibility

    var body: some View {
        VStack(spacing: 0) {
            // Format bounds + place toast overlay by platform
#if os(iOS)
            ScrollView(.vertical) {
                iOSDeviceDetailLayout(chain: chain,details: details)
                    .padding(.bottom, 20)
            }
            .ignoresSafeArea(.container, edges: [.bottom])
            .background(bg.ignoresSafeArea())
            .overlay(
                ToastServer(vm: vc.toast as! MWToastServerVM)
                    .accessibilityHidden(true)
                    .shadow(color: iOSToastShadowColor, radius: 15, x: 0, y: 10),
                alignment: .top)

#elseif os(macOS)

            ScrollView(.vertical) {
                MacDeviceDetailLayout(chain: chain, details: details)
            }
            .fontBody()
            .padding(.leading)
            .overlay(ToastServer(vm: vc.toast as! MWToastServerVM).accessibilityHidden(true), alignment: .top)
#endif
        }
        .toolbar {
            Toolbar(store: vc.signals as! MWSignalsStore,
                    vm: vc.vms.header as! DetailHeaderSUIVC)

        }
        .pickerStyle(SegmentedPickerStyle())
        .accessibilityLabel("Details for Currently Connected Device")
        .accessibilityLinkedGroup(id: "details", in: chain)
    }

    private var bg: some View { Color.groupedListBackground }

    var iOSToastShadowColor: Color {
        colorScheme == .light
        ? .black.opacity(0.1)
        : .black.opacity(0.15)
    }
}
