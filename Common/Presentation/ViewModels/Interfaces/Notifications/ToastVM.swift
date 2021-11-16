//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

public protocol ToastVM: AnyObject {

    var showToast: Bool { get }
    var text: String { get }
    var type: ToastType { get }
    var animationDuration: Double { get }
    var allowBluetoothRequests: Bool { get }
    var percentComplete: Int { get }

    func present(mode: ToastType, _ text: String, disablesInteraction: Bool, onDismiss: (() -> Void)?)

    func update(mode: ToastType?, text: String?, disablesBluetoothActions: Bool?, onDismiss: (() -> Void)?)

    func updateProgress(percentage: Int)

    func dismiss(updatingText: String?, disablesInteraction: Bool?, delay: Double)

    func userTappedToDismiss()

    /// Destroys references
    func clearAllToasts()
}

public extension ToastVM {

    func update(_ mode: ToastType? = nil, text: String? = nil, disablesBluetoothActions: Bool? = nil, onDismiss: (() -> Void)? = nil) {
        update(mode: mode, text: text, disablesBluetoothActions: disablesBluetoothActions, onDismiss: onDismiss)
    }

    func dismiss(delay: Double = .defaultToastDismissalDelay) {
        dismiss(updatingText: nil, disablesInteraction: nil, delay: delay)
    }
}

public enum ToastType: Int {
    case foreverSpinner
    case horizontalProgress
    case textOnly
}

public extension Double {
    static let defaultToastDismissalDelay: Double = 1.5
}
