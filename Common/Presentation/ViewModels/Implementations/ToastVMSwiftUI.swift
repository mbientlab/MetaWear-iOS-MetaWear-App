//  © 2021 Ryan Ferrell. github.com/importRyan

import SwiftUI

extension EnvironmentValues {
    var allowBluetoothRequests: Bool {
        get { return self[AllowBluetoothRequestsKey.self] }
        set { self[AllowBluetoothRequestsKey.self] = newValue }
    }
}

private struct AllowBluetoothRequestsKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

public class ToastVMSwiftUI: ObservableObject {

    public private(set) var showToast                   = false
    public private(set) var text                        = ""
    public private(set) var percentComplete: Int        = 0
    public private(set) var type: HUDMode               = .foreverSpinner
    public let animationDuration: Double   = 0.25
    public private(set) var allowBluetoothRequests      = true

    private var canShowNewToast = true
    private var didDismissCallback: (() -> Void)? = nil
    private var queuedToast: (() -> Void)? = nil

    private func hideThenReset() {
        showToast = false
        self.objectWillChange.send()
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.text                      = ""
            self?.percentComplete           = 0
            self?.type                      = .foreverSpinner
            self?.allowBluetoothRequests    = true
            self?.objectWillChange.send()

            self?.canShowNewToast           = true
            self?.queuedToast?()
        }
    }
}

extension ToastVMSwiftUI: ToastVM {

    public func userTappedToDismiss() {
        hideThenReset()
        didDismissCallback?()
    }

    public func present(_ mode: HUDMode,
                 _ text: String,
                 disablesInteraction: Bool,
                 onDismiss: (() -> Void)?) {

        guard canShowNewToast else {
            queuedToast = { [weak self] in
                self?.present(mode,
                              text,
                              disablesInteraction: disablesInteraction,
                              onDismiss: onDismiss)
            }
            return
        }

        self.canShowNewToast = false
        self.showToast = true
        self.text = text
        self.type = mode
        self.allowBluetoothRequests = !disablesInteraction
        self.didDismissCallback = onDismiss
        self.objectWillChange.send()
    }

    public func updateProgress(percentage: Int) {
        percentComplete = percentage
        self.objectWillChange.send()
    }

    public func update(mode: HUDMode?,
                text: String?,
                disablesInteraction: Bool?,
                onDismiss: (() -> Void)?) {

        if let updateMode = mode {
            self.type = updateMode
        }

        if let updateText = text {
            self.text = updateText
        }

        if let updateInteraction = disablesInteraction {
            self.allowBluetoothRequests = !updateInteraction
        }

        if let updateDismiss = onDismiss {
            self.didDismissCallback = updateDismiss
        }

        self.objectWillChange.send()
    }

    public func dismiss(updatingText: String?, disablesInteraction: Bool?, delay: Double) {

        if let updateText = updatingText {
            self.text = updateText
        }

        if let updateInteraction = disablesInteraction {
            self.allowBluetoothRequests = !updateInteraction
        }

        self.objectWillChange.send()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.hideThenReset()
        }
    }

    public func clearAllToasts() {
        didDismissCallback = nil
        queuedToast = nil
        hideThenReset()
    }
}
