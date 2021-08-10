//
//  SignalDots.swift
//  SignalDots
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SignalDots: View {

    @ObservedObject var vc: ScannedDeviceCellSUIVC
    var dotSize: CGFloat = 5
    var spacing: CGFloat = 2
    var color: Color? = nil

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(vc.signalActiveDots, id: \.self) { _ in
                Circle()
                    .frame(width: dotSize, height: dotSize)
            }

            ForEach(vc.signalInactiveDots, id: \.self) { _ in
                Circle()
                    .stroke()
                    .frame(width: dotSize, height: dotSize)
                    .opacity(0.5)
            }
        }
        .foregroundColor(foreground)
    }

    var foreground: Color { color ?? .accentColor }
}

