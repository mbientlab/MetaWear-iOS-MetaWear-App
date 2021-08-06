//
//  SignalDots.swift
//  SignalDots
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SignalDots: View {

    var dots: Int
    var maxDots: Int = 5
    var dotSize: CGFloat = 12
    var spacing: CGFloat = 3

    private var activeDots: Int { min(dots, maxDots) }
    private var inactiveDots: Int { max(0, maxDots - dots) }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<activeDots) { _ in
                Circle()
                    .frame(width: dotSize, height: dotSize)
            }

            ForEach(0..<inactiveDots) { _ in
                Circle()
                    .stroke()
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .foregroundColor(.signalObtained)
    }
}
