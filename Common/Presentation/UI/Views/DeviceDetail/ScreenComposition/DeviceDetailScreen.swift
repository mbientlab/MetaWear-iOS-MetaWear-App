//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

struct DeviceDetailScreen: View {

    @ObservedObject var toast: MWToastServerVM
    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.fontFace) private var fontFace

    var chain: Namespace.ID // accessibility
    @Namespace var details // accessibility

    // MARK: - Place Toast notifications. Wrap accessibility and styling.

    var body: some View {
        VStack(spacing: 0) {

            #if os(iOS)

            scrollView
                .ignoresSafeArea(.container, edges: [.bottom])
                .background(bg.ignoresSafeArea())
                .overlay(
                    toastServer
                        .accessibilityHidden(true)
                        .shadow(color: iOSToastShadowColor, radius: 15, x: 0, y: 10),
                    alignment: .top)

            #elseif os(macOS)

            scrollView
                .fontBody()
                .padding(.leading)
                .overlay(toastServer.accessibilityHidden(true), alignment: .top)

            #endif

        }
        .toolbar {
            Toolbar(store: vc.signals as! MWSignalsStore,
                    vm: vc.vms.header as! DetailHeaderSUIVC)

        }

        .pickerStyle(SegmentedPickerStyle())

        .animation(.easeOut, value: vc.toast.showToast)
        .animation(.easeOut(duration: 0.25), value: vc.sortedVisibleGroups)
        .animation(.none)

        .accessibilityLabel("Details for Currently Connected Device")
        .accessibilityLinkedGroup(id: "details", in: chain)
    }

    var toastServer: some View {
        ToastServer(vm: vc.toast as! MWToastServerVM)
    }

    private var bg: some View { Color.groupedListBackground }

    // MARK: - Define content layout by platform

    var scrollView: some View {
        ScrollViewReader { scroll in
            ScrollView(.vertical) {
                #if os(macOS)
                GridLayout(details: details, alignment: .topLeading, forInfoPanels: true)
                    .padding(.bottom, 20)
                    .padding(.top, fontFace == .openDyslexic ? 28 : 18)
                    .padding(.bottom, .cardGridSpacing)

                GridLayout(details: details, alignment: .topLeading, forInfoPanels: false)
                    .padding(.bottom, 20)
                    .padding(.top, fontFace == .openDyslexic ? 28 : 18)

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

    var iOSToastShadowColor: Color {
        colorScheme == .light
            ? .black.opacity(0.1)
            : .black.opacity(0.15)
    }
}
