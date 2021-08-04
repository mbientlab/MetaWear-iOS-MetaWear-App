//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct HeaderBlock: View {

    @ObservedObject var vm: MWDetailHeaderSVC

    var body: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            title
            connection
        }
    }

    @State private var shake = 0
    @State private var didEdit = false
    @State private var deviceTitle = ""
    var title: some View {
        HStack {
            TextField(
                "Device",
                text: $deviceTitle) { didEdit in
                    self.didEdit = true
                } onCommit: {
                    validateName()
                }
                .font(.largeTitle)

            Button("Save") { validateName() }
            .opacity(didEdit ? 1 : 0)
            .allowsHitTesting(didEdit)
            .disabled(!didEdit)
        }
        .onAppear { deviceTitle = vm.deviceName }
        .onChange(of: vm.deviceName) { deviceTitle = $0 }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarConnectionButton
            }
        }
        .navigationTitle(vm.deviceName)
    }

    var toolbarConnectionButton: some View {
        Button { if !vm.connectionIsOn { vm.userSetConnection(to: true) } } label: {
            Image(systemName: vm.connectionIsOn ? SFSymbol.connected.rawValue : SFSymbol.disconnected.rawValue)
                .foregroundColor(vm.connectionIsOn ? Color(.systemBlue) : Color(.systemPink))
        }
        .accessibilityLabel(vm.connectionIsOn ? "Connected" : "Disconnected")
        .accessibilityAddTraits(.isButton)
    }

    func validateName() {
        self.didEdit = false
        guard vm.didUserTypeValidDevice(name: deviceTitle)
        else { shakeAnimation(); return }
        vm.userUpdatedName(to: deviceTitle)
        UIApplication.firstKeyWindow()?.resignFirstResponder()
    }

    func shakeAnimation() {
        shake += 1
    }

    var isConnected: Binding<Bool> {
        Binding { vm.connectionIsOn }
        set: { vm.userSetConnection(to: $0) }
    }

    var connection: some View {
        HStack {
            Text(vm.connectionState)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: isConnected)
                .fixedSize()
        }

    }
}
