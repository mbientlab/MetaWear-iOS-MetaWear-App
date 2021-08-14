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
                .fontBody(weight: .medium)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
        }
        .padding(12)
        .background(
            ZStack {
                Capsule().fill(Color.toastPillBackground)
                #if os(iOS)
                Capsule().stroke(Color.secondary.opacity(0.45))
                #elseif os(macOS)
                Capsule().stroke(Color.secondary.opacity(0.3))
                #endif
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 10)
        )
        .padding(15)
        .onTapGesture { vm.userTappedToDismiss() }
    }

    @ViewBuilder private var progressIndicator: some View {
        switch vm.type {

            case .textOnly:
                EmptyView()

            case .horizontalProgress:

                Text(String(vm.percentComplete))
                    .fontSmall(weight: .medium, monospacedDigit: true)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.leading, 10)

                ProgressView(value: Float(vm.percentComplete) / 100, total: 1)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    .padding(.horizontal)
                    .frame(width: 125)

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
