//  Created by Ryan Ferrell on 8/15/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct TapToConnectPrompt: View {

    var didNavigate: Bool

    @EnvironmentObject private var prefs: PreferencesStore
    @EnvironmentObject private var vc: MetaWearScanningSVC
    @State private var didAppear = false

    var body: some View {
        VStack {
            if !prefs.didOnboard && !vc.discoveredDevices.isEmpty && !didNavigate {
                VStack(alignment: .center) {
                    Arrow()
                        .stroke(arrowGradient)
                        .scaledToFit()
                        .frame(height: 25)
                        .offset(y: didAppear ? 0 : -8)
                        .animation(animation, value: didAppear)

                    Text("Tap to connect")
                        .fontSmall(weight: .medium)
                        .opacity(0.85)
                }
                .onAppear { didAppear = true }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 15)
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.5), value: !vc.discoveredDevices.isEmpty && !didNavigate)
        .onChange(of: didNavigate) { _ in
            prefs.setDidOnboard(true)
        }
    }

    var animation: Animation {
        .interpolatingSpring(stiffness: 400, damping: 9, initialVelocity: 10)
    }

    var arrowGradient: LinearGradient {
        LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.35)],
                               startPoint: .top,
                               endPoint: .bottom)
    }
}

struct Arrow: Shape {

    var arrowWidth: CGFloat = 0.26
    var arrowHeight: CGFloat = 0.22

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        let xLeft = (1 - arrowWidth) * width
        let xCenter = 0.5 * width
        let xRight = arrowWidth * width

        let yTop = 0 * height
        let yArrowLines = arrowHeight * height
        let yBottom = 1 * height

        path.move(to: CGPoint(x: xLeft, y: yArrowLines))
        path.addLine(to: CGPoint(x: xCenter, y: yTop))
        path.addLine(to: CGPoint(x: xRight, y: yArrowLines))
        path.move(to: CGPoint(x: xCenter, y: yTop))
        path.addLine(to: CGPoint(x: xCenter, y: yBottom))
        return path
    }
}
