//
//  CopyMacButton.swift
//  CopyMacButton
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct CopyButton: View {

    var string: String
    var label: String

    var body: some View {
        Button(label) {
            #if os(macOS)
            NSPasteboard.general.setString(string, forType: .string)
            #elseif os(iOS)
            UIPasteboard.general.string = string
            #endif
        }
    }
}
