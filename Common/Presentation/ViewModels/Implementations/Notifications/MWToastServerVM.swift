//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MWToastServerVM: ObservableObject {

    public private(set) var showToast                   = false
    public private(set) var text                        = ""
    public private(set) var percentComplete: Int        = 0
    public private(set) var type: ToastType               = .foreverSpinner
    public let animationDuration: Double   = 0.25
    public private(set) var allowBluetoothRequests      = true

    private var canShowNewToast = true
    private var didDismissCallback: (() -> Void)? = nil
    private var queuedToast: (() -> Void)? = nil
}

extension MWToastServerVM: ToastVM {

    public func userTappedToDismiss() {
        guard allowBluetoothRequests else { return }
        hideThenReset()
        didDismissCallback?()
    }

    public func present(mode: ToastType,
                 _ text: String,
                 disablesInteraction: Bool,
                 onDismiss: (() -> Void)?) {

        guard canShowNewToast else {
            queuedToast = { [weak self] in
                self?.present(mode: mode,
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
        objectWillChange.send()
    }

    public func update(mode: ToastType?,
                text: String?,
                disablesBluetoothActions: Bool?,
                onDismiss: (() -> Void)?) {

        if let updateMode = mode {
            self.type = updateMode
        }

        if let updateText = text {
            self.text = updateText
        }

        if let updateInteraction = disablesBluetoothActions {
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

private extension MWToastServerVM {

    func hideThenReset() {
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
