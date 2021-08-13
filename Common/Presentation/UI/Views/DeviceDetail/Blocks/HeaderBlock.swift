//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct HeaderBlock: View {

    @ObservedObject var vm: DetailHeaderSUIVC

    var body: some View {
        #if os(macOS)
        header.navigationTitle(vm.deviceName)
        #else
        header.navigationBarTitle(vm.deviceName, displayMode: .inline)
        #endif
    }

    var header: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            DeviceTitleEditor(vm: vm)
            #if os(iOS)
            ConnectionToggle(vm: vm)
            #endif
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                ConnectionToolbarButton(vm: vm)
                    .accentColor(.accentColor)
                    .foregroundColor(.accentColor)
            }
            #else
            ToolbarItemGroup(placement: .status) {
                ConnectionToolbarButton(vm: vm)
            }
            #endif
        }
    }
}

// MARK: - Connection
struct ConnectionToggle: View {

    @ObservedObject var vm: DetailHeaderSUIVC

    var body: some View {
        HStack {
            #if os(iOS)
            stateLabel
            toggle
            #else
            toggle
            stateLabel
            #endif
        }
    }

    private var stateLabel: some View {
        Text(vm.connectionState)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }


    private var toggle: some View {
        Toggle("", isOn: isConnected)
            .fixedSize()
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    }

    private var isConnected: Binding<Bool> {
        Binding { vm.connectionIsOn }
            set: { vm.userSetConnection(to: $0) }
    }
}

// MARK: - Title
struct DeviceTitleEditor: View {

    @ObservedObject var vm: DetailHeaderSUIVC
    @Environment(\.fontFace) private var fontFace

    @State private var shake = false
    @State private var didEdit = false
    @State private var deviceTitle = ""
    @State private var showValidationNotice = false

    var body: some View {
        HStack {
            #if os(macOS)
            macTextField
            #else
            textField
            #endif
            save
        }
        .onAppear { deviceTitle = vm.deviceName }
        .onChange(of: vm.deviceName) { deviceTitle = $0 }

        .modifier(ShakeEffect(shakes: shake ? 2 : 0))
        .animation(shake ? Animation.easeIn.speed(2) : .none, value: shake)

        .background(validationNotice.offset(y: 20), alignment: .bottom)
        .animation(.easeIn, value: showValidationNotice)

    }
    #if os(macOS)
    private var macTextField: some View {
        SingleLineTextField(initialText: vm.deviceName,
                            placeholderText: "Name",
                            config: .largeDeviceStyle(face: fontFace),
                            onCommit: validateTextFieldCommit,
                            onCancel: { }
        )
        .frame(width: .detailBlockWidth * 0.7,
               height: fontFace == .openDyslexic ? 30 : 25,
               alignment: .leading)
        .offset(y: 2)
    }

    func validateTextFieldCommit(_ string: String) {
        deviceTitle = string
        validateName()
    }
    #endif

    private var textField: some View {
        TextField("Device", text: $deviceTitle) { didEdit in
            self.didEdit = true
        } onCommit: {
            validateName()
        }
        .font(.title2)
    }

    private var save: some View {
        Button("Save") { validateName() }
            .opacity(didEdit ? 1 : 0)
            .allowsHitTesting(didEdit)
            .disabled(!didEdit)
            .accessibilityHidden(!didEdit)
    }

    @ViewBuilder
    private var validationNotice: some View {
        if showValidationNotice {
            Text(vm.deviceNameRequirementsMessage)
                .fontSmall()
                .foregroundColor(.primary)
                .padding()
                .background(Capsule().fill(Color.toastPillBackground))
                .transition(.move(edge: .top))
        }
    }
}

private extension DeviceTitleEditor {

    func shakeAnimation() {
        shake.toggle()
    }

    func flashValidationNotice() {
        showValidationNotice = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showValidationNotice = false
        }
    }

    func validateName() {
        self.didEdit = false
        guard vm.didUserTypeValidDevice(name: deviceTitle) else {
            shakeAnimation()
            flashValidationNotice()
            return
        }
        vm.userRenamedDevice(to: deviceTitle)
        #if os(iOS)
        UIApplication.firstKeyWindow()?.resignFirstResponder()
        #else
        NSApp.resignFirstResponder()
        #endif
    }
}
