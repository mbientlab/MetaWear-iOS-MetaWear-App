//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//
import SwiftUI

struct Header: View {

    @ObservedObject var vm: IdentifiersSUIVC
    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.fontFace) private var fontFace

    // MARK: - Device-Specific Layouts

    var body: some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            ipadOSImageOffCenterOverlaid
        } else {
            iOSImageAbove
        }
#elseif os(macOS)
        macOSImageOverlaid
#endif
    }

    var iOSImageAbove: some View {
        VStack(spacing: .cardGridSpacing) {
            deviceImage
                .compositingGroup()
                .shadow(color: .black.opacity(0.11), radius: 3, x: 5, y: 7)

            headerCard
        }
    }

    var ipadOSImageOffCenterOverlaid: some View {
        headerCard
            .overlay(deviceImage.offset(x: .detailBlockWidth * 0.10), alignment: .center)
            .padding(.top, fontFace == .openDyslexic ? 26 : 16)
    }

    var macOSImageOverlaid: some View {
        HeaderBlock(vm: vc.vms.header as! DetailHeaderSUIVC)
            .opacity(vm.model == .notFound ? 0 : 1)
            .animation(.easeOut, value: vm.model == .notFound)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(vc.vms.header.deviceName) is \(vc.vms.header.connectionState)")
            .accessibilityHint("Edit device name")
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: imageSize)

            .overlay(deviceImage.offset(x: -40), alignment: .trailing)
            .padding(.top, 12)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        75
        #else
        100
        #endif
    }

    // MARK: - Components

    var headerCard: some View {
        TitlelessDetailsBlockCard(
            tag: DetailGroup.headerInfoAndState.id,
            content: HeaderBlock(vm: vc.vms.header as! DetailHeaderSUIVC)
        )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(vc.vms.header.deviceName) is \(vc.vms.header.connectionState)")
            .accessibilityHint("Edit device name")
    }

    var deviceImage: some View {
        DeviceImage(vm: vm,
                    header: vc.vms.header as! DetailHeaderSUIVC,
                    size: imageSize
        )
    }
}
