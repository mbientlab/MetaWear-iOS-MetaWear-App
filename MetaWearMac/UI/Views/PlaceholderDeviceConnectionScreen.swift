//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct PlaceholderDeviceConnectionScreen: View {

    @EnvironmentObject private var prefs: PreferencesStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect().dropFirst()
    @State private var iteration = 0

    var body: some View {
        VStack {

            Text("Bring your devices nearby").opacity(0.85)
                .fontLarger()
                .accessibilitySortPriority(10)

            metamotionS
                .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    iteration += 1
                }}
                .onReceive(timer) { _ in
                    guard !reduceMotion else { return }
                    iteration += 1
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Spinning MetaMotion devices")
                .accessibilityAddTraits(.isImage)

                .padding(.top, 70)

        }
        .animation(.spring(response: 0.8, dampingFraction: 0.79, blendDuration: 0.2).speed(1.1), value: iteration)
        .offset(y: -50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay(dyslexic.accessibilitySortPriority(10).padding(30), alignment: .bottom)
        .toolbar {
            // Ensure unified window titlebar styling in absence of any other buttons
            Button(" ") { }
            .accessibilityHidden(true)
        }
    }

    private var metamotionS: some View {
        Image(Images.metamotionS.catalogName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: size, maxHeight: size)
            .modifier(SpinEffect(degrees: CGFloat(iteration) * 360))
    }

    private let size = CGFloat(100)

    private var binding: Binding<FontFace> {
        Binding { [weak prefs] in
            prefs?.font ?? .system
        } set: { [weak prefs] newState in
            prefs?.setFont(face: newState)
        }
    }

    private var dyslexic: some View {
        Menu("                       ") {
            ForEach(FontFace.allCases) { face in
                Button(face.name) { binding.wrappedValue = face }
                if face == .system {
                    Divider()
                }
            }
        }
        .accessibilityLabel("Dyslexic Font Options")
        .frame(width: prefs.font == .openDyslexic ? 125 : 95)
        .animation(.easeOut, value: prefs.font)
        .fixedSize()
        .controlSize(.large)
        .overlay(Text("Dyslexic?").accessibility(hidden: true).allowsHitTesting(false))
    }
}

