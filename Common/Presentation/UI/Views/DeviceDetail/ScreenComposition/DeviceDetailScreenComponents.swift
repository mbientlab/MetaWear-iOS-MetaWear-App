//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//
import SwiftUI

struct Header: View {

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC

    var body: some View {
        #if os(iOS)
        deviceImageHero
            .padding(.bottom, -20)
            .offset(y: 20)

        headerCard

        #elseif os(macOS)

        headerCard
            .overlay(deviceImageOverlay, alignment: .trailing)

        #endif
    }

    var headerCard: some View {
        TitlelessDetailsBlockCard(
            tag: DetailGroup.headerInfoAndState.id,
            content: HeaderBlock(vm: vc.vms.header as! DetailHeaderSUIVC)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(vc.vms.header.deviceName) is \(vc.vms.header.connectionState)")
        .accessibilityHint("Edit device name")
    }

    var deviceImageOverlay: some View {
        DeviceImage(vm: vc.vms.identifiers as! IdentifiersSUIVC,
                    header: vc.vms.header as! DetailHeaderSUIVC)
    }

    var deviceImageHero: some View {
        DeviceImage(vm: vc.vms.identifiers as! IdentifiersSUIVC,
                    header: vc.vms.header as! DetailHeaderSUIVC,
                    size: 155)
    }
}


struct IdentitySection: View {

    var details: Namespace.ID

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.fontFace) private var fontFace

    var body: some View {
        Header().padding(.top, fontFace == .openDyslexic ? 26 : 16)

        ForEach(vc.sortedVisibleGroups) { group in
            if group.isInfo {
                BlockBuilder(group: group, namespace: details)
            }
        }
        .animation(.easeOut(duration: 0.15))
    }
}


struct SensorsSection: View {

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
