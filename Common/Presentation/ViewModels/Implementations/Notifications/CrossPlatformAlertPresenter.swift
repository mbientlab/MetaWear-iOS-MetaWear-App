//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class CrossPlatformAlertPresenter: ObservableObject {}

extension CrossPlatformAlertPresenter: AlertPresenter {
#if os(iOS)
    public func presentAlert(title: String, message: String, in vc: AnyVC?) {
        guard let vc = vc ?? UIApplication.rootKeyVC() else { return }

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "Okay",
            style: .default,
            handler: nil
        )

        alertController.addAction(action)

        vc.present(alertController, animated: true, completion: nil)
    }

#elseif os(macOS)
    public func presentAlert(title: String, message: String, in vc: AnyVC?) {
        NSAlert.presentSuppressableAlert(
            in: vc?.view.window,
            title: title,
            message: message,
            primaryLabel: "OK",
            secondaryLabel: nil,
            showSupression: false) { primaryActionDidRequestSuppress in
                // Feature not implemented
            } secondaryShouldSuppress: { secondaryActionDidRequestSuppress in
                // Feature not implemented
            }
    }
#endif
}

#if os(iOS)
public typealias AnyVC = UIViewController
#else
public typealias AnyVC = NSViewController
#endif

#if os(macOS)
extension NSAlert {
    static func presentSuppressableAlert(
        in window: NSWindow?,
        title: String,
        message: String?,
        primaryIsDestructive: Bool = false,
        primaryLabel: String,
        secondaryLabel: String?,
        secondaryIsDestructive: Bool = false,
        showSupression: Bool,
        primaryShouldSuppress: @escaping (Bool) -> Void,
        secondaryShouldSuppress: @escaping (Bool) -> Void)
    {
        autoreleasepool {
            let alert = NSAlert()
            alert.showsSuppressionButton = showSupression
            alert.messageText = title
            if let info = message {
                alert.informativeText = info
            }

            alert.addButton(withTitle: primaryLabel)

            if primaryIsDestructive {
                alert.buttons.first?.hasDestructiveAction = true
            }

            if let secondary = secondaryLabel {
                alert.addButton(withTitle: secondary)
                if secondaryIsDestructive {
                    alert.buttons[1].hasDestructiveAction = true
                }
            }

            guard let window = window ?? NSApplication.shared.keyWindow else { return }
            alert.beginSheetModal(for: window) { [weak alert] userResponse in
                switch userResponse {
                    case .alertFirstButtonReturn: primaryShouldSuppress(alert?.suppressionButton?.state == .on)
                    case .alertSecondButtonReturn: secondaryShouldSuppress(alert?.suppressionButton?.state == .on)
                    default: primaryShouldSuppress(alert?.suppressionButton?.state == .on)
                }
            }
        }
    }
}
#endif
