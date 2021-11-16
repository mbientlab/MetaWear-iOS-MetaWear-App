//
//  DeviceImage.swift
//  DeviceImage
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DeviceImage: View {

    @ObservedObject var vm: IdentifiersSUIVC
    @ObservedObject var header: DetailHeaderSUIVC
    var size: CGFloat = 115

    @State private var imageName: String?
    @State private var showLED = false
    private let ledColor = Color(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.8)

    @Environment(\.colorScheme) private var colorScheme
    var shadow: Color { colorScheme == .dark ? .black.opacity(0.08) : .white.opacity(0.5) }

    var body: some View {
        VStack(spacing: 0) {
            if let image = imageName {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .shadow(color: shadow, radius: 20, x: 0, y: 0)
                    .overlay(ledMockup.animation(.easeIn(duration: 0.15), value: imageName).offset(y: size * 0.4), alignment: .top)
                    .transition(.scale(scale: 0.75).combined(with: .opacity))
            }
        }
        .onChange(of: vm.model.bundleName) { image in
                imageName = image
        }
        .animation(.spring(), value: imageName)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(vm.model.isolatedModelName) Flashed LED Light On Connection")
        .accessibilityAddTraits(.isImage)
    }


    @ViewBuilder var ledMockup: some View {
        if header.connectionIsOn {
            ZStack {
                Circle().fill(ledColor)
                    .frame(width: size * 0.1, height: size * 0.1)
                    .blur(radius: 3)

                Circle().fill(ledColor)
                    .frame(width: size * 0.1, height: size * 0.1)
                    .blur(radius: showLED ? 9 : 3)


                Circle().fill(ledColor)
                    .frame(width: size * 0.1, height: size * 0.1)
                    .blur(radius: showLED ? 15 : 3)
            }
            .opacity(showLED ? 1 : 0)
            .animation(.easeOut(duration: 0.15), value: showLED)

            .onAppear { if !header.didShowConnectionLED {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    runFlashing()
                    header.didShowConnectionLED = true
                }
            } }
            .transition(.opacity)
        }
    }

    func runFlashing() {
        flash()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            flash()
        }

    }

    func flash() {
        showLED = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showLED = false
        }
    }
}
