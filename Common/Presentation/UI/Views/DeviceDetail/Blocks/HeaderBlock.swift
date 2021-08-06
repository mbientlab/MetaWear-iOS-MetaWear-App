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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarConnectionButton
            }
        }
        .navigationTitle(vm.deviceName)
    }

    @State private var shake = false
    @State private var didEdit = false
    @State private var deviceTitle = ""
    private var title: some View {
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

        .modifier(ShakeEffect(shakes: shake ? 2 : 0))
        .animation(shake ? Animation.easeIn.speed(2) : .none, value: shake)
        
    }

    private var toolbarConnectionButton: some View {
        Button { if !vm.connectionIsOn { vm.userSetConnection(to: true) } } label: {
            Image(systemName: vm.connectionIsOn ? SFSymbol.connected.rawValue : SFSymbol.disconnected.rawValue)
                .foregroundColor(vm.connectionIsOn ? Color(.systemBlue) : Color(.systemPink))
        }
        .accessibilityLabel(vm.connectionIsOn ? "Connected" : "Disconnected")
        .accessibilityAddTraits(.isButton)
    }

    private func validateName() {
        self.didEdit = false
        guard vm.didUserTypeValidDevice(name: deviceTitle)
        else { shakeAnimation(); return }
        vm.userUpdatedName(to: deviceTitle)
        UIApplication.firstKeyWindow()?.resignFirstResponder()
    }

    private func shakeAnimation() {
        shake.toggle()
    }

    private var isConnected: Binding<Bool> {
        Binding { vm.connectionIsOn }
        set: { vm.userSetConnection(to: $0) }
    }

    private var connection: some View {
        HStack {
            Text(vm.connectionState)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: isConnected)
                .fixedSize()
                .toggleStyle(SwitchToggleStyle(tint: Color(.systemBlue)))
        }

    }
}
