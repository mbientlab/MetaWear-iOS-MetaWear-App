//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

public protocol ToastVM: AnyObject {

    var showToast: Bool { get }
    var text: String { get }
    var type: HUDMode { get }
    var animationDuration: Double { get }
    var allowBluetoothRequests: Bool { get }
    var percentComplete: Int { get }

    func present(_ mode: HUDMode, _ text: String, disablesInteraction: Bool, onDismiss: (() -> Void)?)
    func update(mode: HUDMode?, text: String?, disablesInteraction: Bool?, onDismiss: (() -> Void)?)
    func updateProgress(percentage: Int)
    func dismiss(updatingText: String?, disablesInteraction: Bool?, delay: Double)

    func userTappedToDismiss()

    /// Destroys references
    func clearAllToasts()
}

public enum HUDMode {
    case foreverSpinner
    case horizontalProgress
    case textOnly
}

public extension Double {
    static let defaultToastDismissalDelay: Double = 1.5
}

public extension ToastVM {

    func dismiss(delay: Double = .defaultToastDismissalDelay) {
        dismiss(updatingText: nil, disablesInteraction: nil, delay: delay)
    }
}
