//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

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
