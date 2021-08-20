//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ExportDataButton: View {

    var label: String = "Export"
    var isEnabled: Bool
    var isPreparing: Bool
    var action: () -> Void

    var body: some View {

        activeButton
                .opacity(isPreparing ? 0 : 1)
                .overlay(preparingSpinner)

        .help("Export")
        .accessibilityLabel(label.isEmpty ? "Export" : label)
        .accessibilityAddTraits(.isButton)
        .disabled(!isEnabled)
        .allowsHitTesting(isEnabled)
        .animation(.easeOut, value: isPreparing)
        .animation(.easeInOut, value: isEnabled)
    }

    var activeButton: some View {
        Button { action() } label: {
            Label(label, systemImage: SFSymbol.send.rawValue)
                .lineLimit(1)
        }
        .offset(y: -4)
        .opacity(isEnabled ? 1 : 0)
    }

    @ViewBuilder var preparingSpinner: some View {
        if isPreparing {
            SmallCircularProgressView()
                .accessibilityLabel("Preparing file for export")
        }
    }
}

struct SmallCircularProgressView: View {

    var body: some View {
#if os(macOS)
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .transition(.opacity)
            .controlSize(.small)
#elseif os(iOS)
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .transition(.scale)
#endif
    }
}
