//
//  EmptyDevicesListButton.swift
//  EmptyDevicesListButton
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct EmptyDevicesListButton: View {

    @EnvironmentObject private var vc: MetaWearScanningSVC

    var body: some View {
        if vc.isScanning {
            Text("Searching")
        } else {
            Button("Start Scanning") { vc.userChangedScanningState(to: true) }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

}
