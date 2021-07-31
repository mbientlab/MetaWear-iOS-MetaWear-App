//
//  PresentAlert.swift
//  PresentAlert
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

func presentAlert(in vc: UIViewController, title: String, message: String) {

    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)

    let action = UIAlertAction(title: "Okay",
                               style: .default,
                               handler: nil)

    alertController.addAction(action)

    vc.present(alertController, animated: true, completion: nil)
}
#endif
