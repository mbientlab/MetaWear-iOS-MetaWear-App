//
//  PresentAlert.swift
//  PresentAlert
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

#if os(iOS)
public typealias AnyVC = UIViewController
#else
public typealias AnyVC = NSViewController
#endif

public protocol AlertPresenter: AnyObject {
    /// Pass nil to present in the key window
    func presentAlert(title: String, message: String, in vc: AnyVC?)

}

extension AlertPresenter {

    /// Present in key window
    func presentAlert(title: String, message: String) {
        presentAlert(title: title, message: message, in: nil)
    }
}

public class CrossPlatformAlertPresenter: AlertPresenter, ObservableObject {

#if os(iOS)
    public func presentAlert(title: String, message: String, in vc: AnyVC?) {


        guard let vc = vc ?? rootKeyVC() else { return }

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

    private func rootKeyVC() -> UIViewController? {
        UIApplication.shared.windows
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
#endif

}
