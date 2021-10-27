//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//
import SwiftUI

struct Header: View {

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
                .padding(.bottom, -20)
                .offset(y: 20)
                .padding(.top, fontFace == .openDyslexic ? 26 : 16)

            headerCard
        }
    }

    var ipadOSImageOffCenterOverlaid: some View {
        headerCard
            .overlay(deviceImage.offset(x: .detailBlockWidth * 0.15), alignment: .center)
            .padding(.top, fontFace == .openDyslexic ? 26 : 16)
    }

    var macOSImageOverlaid: some View {
        headerCard
            .overlay(deviceImage, alignment: .trailing)
            .padding(.top, fontFace == .openDyslexic ? 26 : 16)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        115
        #else
        UIDevice.current.userInterfaceIdiom == .pad ? 225 : 155
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
        DeviceImage(vm: vc.vms.identifiers as! IdentifiersSUIVC,
                    header: vc.vms.header as! DetailHeaderSUIVC,
                    size: imageSize
        )
    }
}
