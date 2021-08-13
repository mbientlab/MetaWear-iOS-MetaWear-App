//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

struct DeviceDetailScreen: View {

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.colorScheme) private var colorScheme

    var chain: Namespace.ID
    @Namespace var details

    // MARK: - Place Toast notifications. Wrap accessibility and styling.

    var body: some View {
        VStack(spacing: 0) {
            scrollView
#if os(iOS)
                .ignoresSafeArea(.container, edges: [.bottom])
                .background(bg.ignoresSafeArea())
#endif
        }
        .pickerStyle(.segmented)
        .environment(\.allowBluetoothRequests, vc.toast.allowBluetoothRequests)
        .animation(.easeOut, value: vc.toast.showToast)
        .animation(.none)
        .accessibilityLabel("Details for Currently Connected Device")
        .accessibilityLinkedGroup(id: "details", in: chain)
#if canImport(AppKit)
        .fontBody()
        .padding(.leading)
        .overlay(ToastServer(vm: vc.toast as! MWToastServerVM).accessibilityHidden(true), alignment: .top)
#elseif os(iOS)
        .overlay(ToastServer(vm: vc.toast as! MWToastServerVM)
                    .accessibilityHidden(true)
                    .shadow(color: colorScheme == .light
                            ? .black.opacity(0.1)
                            : .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    ,
                 alignment: .top)
#endif

    }

    private var bg: some View {
        Color.groupedListBackground
    }

    // MARK: - Define content layout by platform in ScrollView

    var scrollView: some View {
        ScrollViewReader { scroll in
            ScrollView(.vertical) {
#if os(macOS)
                MacGridLayout(
                    leftColumn: LeftColumn(details: details),
                    rightGridItems: RightColumns(details: details)
                ).padding(.bottom, 20)
#else
                iOSDeviceDetailLayout(
                    chain: chain,
                    details: details
                ).padding(.bottom, 20)
#endif
            }
            .environment(\.scrollProxy, scroll)
        }
    }
}
