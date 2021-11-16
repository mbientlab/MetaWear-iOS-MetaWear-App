//
//  ScanButton.swift
//  ScanButton
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ScanButton: View {
    
    @EnvironmentObject private var vc: MetaWearScanningSVC
    
    var isOn: Binding<Bool>{
        Binding { vc.isScanning } set: { vc.userChangedScanningState(to: $0) }
    }
    
    var body: some View {
        HStack {
            
            Text("Scan")
                .fontBody()
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(1)
                .accessibilityHidden(true)
            
            Spacer()
            
            Toggle(isOn: isOn) {}
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            .accessibilityLabel("Scanning for MetaWear Devices")
        }
        .animation(.easeOut(duration: 0.25), value: vc.isScanning)
    }
}
