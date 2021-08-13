//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//
import SwiftUI

// On iPad and Mac, there are multiple columns.
// On iPhone, there is just one stacked column.

struct Header: View {

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC

    var body: some View {
        #if os(iOS)
        DeviceImage(vm: vc.vms.identifiers as! IdentifiersSUIVC,
                             header: vc.vms.header as! DetailHeaderSUIVC,
                    size: 155)
            .padding(.bottom, -20)
            .offset(y: 20)
        #endif

        TitlelessDetailsBlockCard(
            tag: DetailGroup.headerInfoAndState.id,
            content: HeaderBlock(vm: vc.vms.header as! DetailHeaderSUIVC)
        )
#if os(macOS)
            .overlay(DeviceImage(vm: vc.vms.identifiers as! IdentifiersSUIVC,
                                 header: vc.vms.header as! DetailHeaderSUIVC),
                     alignment: .trailing)
#endif
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(vc.vms.header.deviceName) is \(vc.vms.header.connectionState)")
            .accessibilityHint("Edit device name")
    }
}

struct LeftColumn: View {

    var details: Namespace.ID

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.fontFace) private var fontFace

    var body: some View {
        Header().padding(.top, fontFace == .openDyslexic ? 38 : 28)

        ForEach(vc.sortedVisibleGroups) { group in
            if group.isInfo {
                BlockBuilder(group: group, namespace: details)
            }
        }
        .animation(.easeOut(duration: 0.15))
    }
}


struct RightColumns: View {

    var details: Namespace.ID
    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC

    var body: some View {
        ForEach(vc.sortedVisibleGroups) { group in
            if !group.isInfo {
                BlockBuilder(group: group, namespace: details)
            }
        }.animation(.none)
    }
}
