//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ToastServer: View {

    @ObservedObject var vm: MWToastServerVM

    var body: some View {
        VStack {
            if vm.showToast {
                toast.transition(.move(edge: .top))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.showToast)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.text)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.percentComplete)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.type)
    }

    private var toast: some View {
        HStack(alignment: .center) {
            progressIndicator

            Text(vm.text)
#if os(iOS)
                .fontSmall(weight: .medium)
#else
                .fontBody(weight: .medium)
#endif
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
        }
        .padding(12)
        .background(toastBackground)
        .padding(15)
        .onTapGesture { vm.userTappedToDismiss() }
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityLabel(accessibilityLabel)
    }

    var accessibilityLabel: String { vm.text + (vm.type == .horizontalProgress ? String(vm.percentComplete) + "%" : "") }

    // MARK: - Background

    var toastBackground: some View {
#if os(iOS)
        let opacity = 0.45
#elseif os(macOS)
        let opacity = 0.3
#endif
        return ZStack {
            if #available(macOS 12.0, iOS 15.0, *) {
                Capsule().fill(.ultraThinMaterial)
            } else {
                Capsule().fill(Color.toastPillBackground)
            }
            Capsule().stroke(Color.secondary.opacity(opacity))
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 10)
    }

    // MARK: - Progress Spinner/Line

    @ViewBuilder private var progressIndicator: some View {
        switch vm.type {

            case .textOnly:
                EmptyView()

            case .horizontalProgress:

                Text(String(vm.percentComplete) + "%")
                    .fontSmall(weight: .medium, monospacedDigit: true)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.leading, 10)

                ProgressView(value: Float(vm.percentComplete) / 100, total: 1)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    .padding(.horizontal)
                    .frame(maxWidth: 120)

            case .foreverSpinner:
#if os(macOS)
                circularSpinner
                    .controlSize(.small)
#else
                circularSpinner
#endif
        }
    }

    private var circularSpinner: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .padding(.leading, 6)
            .padding(.trailing)
    }
}
