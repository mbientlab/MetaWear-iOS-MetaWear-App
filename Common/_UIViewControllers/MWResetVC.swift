//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWDetailResetVC: UIViewController {

    private let vm: DetailResetVM = MWDetailResetVM()

}

extension MWDetailResetVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWDetailResetVC: DetailResetVMDelegate {

    func refreshView() {
        // Nothing
    }

    func presentAlert(title: String, message: String) {
        MetaWearApp.presentAlert(in: self, title: title, message: message)
    }

}

// MARK: - Intents

extension MWDetailResetVC {

    @IBAction func resetDevicePressed(_ sender: Any) {
        vm.userRequestedSoftReset()
    }

    @IBAction func factoryDefaultsPressed(_ sender: Any) {
        vm.userRequestedFactoryReset()
    }

    @IBAction func putToSleepPressed(_ sender: Any) {
        vm.userRequestedSleep()
    }
}
