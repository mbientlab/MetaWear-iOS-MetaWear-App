//
//  MetaBootButton.swift
//  MetaBootButton
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MetaBootCheckButton: View {

    @EnvironmentObject private var vc: MetaWearScanningSVC

    var isOn: Binding<Bool>{
        Binding { vc.useMetaBootMode } set: { vc.userChangedUseMetaBootMode(to: $0) }
    }

    var body: some View {

        HStack {

            Text("MetaBoot")
                .fontBody()
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(1)
                .accessibilityHidden(true)

            Spacer()

            Toggle(isOn: isOn) {}
                .toggleStyle(SwitchToggleStyle(tint: Color(.systemTeal)))
                .accessibilityLabel("MetaBoot Mode")
                .accentColor(Color(.systemTeal))
        }
        .help("Forces boot loader mode (when the device is powering on)")
        .animation(.easeOut(duration: 0.25), value: vc.useMetaBootMode)
    }
}
