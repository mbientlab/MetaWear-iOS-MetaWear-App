//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWDetailFirmwareVC: UIViewController {

    private let vm: DetailFirmwareVM = MWDetailFirmwareVM()

    @IBOutlet weak var fwRevLabel: UILabel!
    @IBOutlet weak var firmwareUpdateLabel: UILabel!
}

extension MWDetailFirmwareVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWDetailFirmwareVC: DetailFirmwareAndResetVMDelegate {

    func refreshView() {
        fwRevLabel.text = vm.firmwareRevision
        firmwareUpdateLabel.text = vm.firmwareUpdateStatus
    }

    func presentAlert(title: String, message: String) {
        MetaWearApp.presentAlert(in: self, title: title, message: message)
    }

}

// MARK: - Intents

extension MWDetailFirmwareVC {

    @IBAction func checkForFirmwareUpdatesPressed(_ sender: Any) {
        vm.userRequestedCheckForFirmwareUpdates()
    }
}
