//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWDetailBatteryVC: UIViewController {

    private let vm: DetailBatteryVM = MWDetailBatteryVM()

    @IBOutlet weak var batteryLevelLabel: UILabel!

}

extension MWDetailBatteryVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWDetailBatteryVC: DetailBatteryVMDelegate {

    func refreshView() {
        self.batteryLevelLabel.text = vm.batteryLevel
    }

    func presentAlert(title: String, message: String) {
        MetaWearApp.presentAlert(in: self, title: title, message: message)
    }
}

// MARK: - Intents

extension MWDetailBatteryVC {

    @IBAction func readBatteryPressed(_ sender: Any) {
        vm.userRequestedBatteryLevel()
    }
}
