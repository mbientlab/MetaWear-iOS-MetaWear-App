//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

struct DeviceDetailScreen: View {

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
                    ToastServer(vm: vc.toast as! MWToastServerVM)
                        .accessibilityHidden(true)
                        .shadow(color: iOSToastShadowColor, radius: 15, x: 0, y: 10),
                    alignment: .top)

            #elseif os(macOS)

            scrollView
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
        .animation(.easeOut(duration: 0.25), value: vc.sortedVisibleGroups)
        .animation(.none)

        .accessibilityLabel("Details for Currently Connected Device")
        .accessibilityLinkedGroup(id: "details", in: chain)
    }

    private var bg: some View { Color.groupedListBackground }

    // MARK: - Define content layout by platform

    var scrollView: some View {
        ScrollViewReader { scroll in
            ScrollView(.vertical) {
#if os(macOS)
                macOSLayout
#else
                iOSDeviceDetailLayout(
                    chain: chain,
                    details: details
                ).padding(.bottom, 20)
#endif
                //            .environment(\.scrollProxy, scroll)
            }
        }
    }

    var macOSLayout: some View {
        VStack(alignment: .leading, spacing: .cardGridSpacing) {

            HStack {
                block(for: .headerInfoAndState)

                if vc.sortedVisibleGroups.contains(.reset) {
                    block(for: .reset)
                        .padding(.leading, .detailBlockColumnSpacing)
                } else {
                    Spacer(minLength: .detailBlockWidth + .detailBlockColumnSpacing)
                }
            }

            ForEach(vc.sortedVisibleGroups.filter { !$0.isInfo }) { group in
                block(for: group)
            }
        }
        .frame(width: .detailBlockWidth * 2 + .detailBlockColumnSpacing, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.top, fontFace == .openDyslexic ? 28 : 18)

    }

    var iOSToastShadowColor: Color {
        colorScheme == .light
            ? .black.opacity(0.1)
            : .black.opacity(0.15)
    }

    func block(for group: DetailGroup) -> some View {
        BlockBuilder(group: group, namespace: details)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(group.title)
            .matchedGeometryEffect(id: group, in: details, properties: .position, anchor: .leading, isSource: false)
    }
}
