//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct ToastServer: View {

    @ObservedObject var vm: ToastServerType

    var body: some View {
        VStack {
            if vm.showToast {
                toast.transition(.move(edge: .top))
            }
        }
        .animation(.easeOut(duration: vm.animationDuration), value: vm.showToast)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.text)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.percentComplete)
        .animation(.easeOut(duration: vm.animationDuration), value: vm.type)
    }

    var toast: some View {
        HStack(alignment: .center) {
            switch vm.type {

                case .textOnly:
                    EmptyView()

                case .horizontalProgress:

                    Text(String(vm.percentComplete))
                        .font(.caption)
                        .fixedSize(horizontal: true, vertical: false)

                    ProgressView(value: Float(vm.percentComplete) / 100, total: 1)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)

                case .foreverSpinner:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.leading, 6)
                        .padding(.trailing)
            }

            Text(vm.text)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
        }
        .padding(12)
        .background(
            Capsule().fill(Color(.systemFill))
        )
        .padding(15)
    }
}
