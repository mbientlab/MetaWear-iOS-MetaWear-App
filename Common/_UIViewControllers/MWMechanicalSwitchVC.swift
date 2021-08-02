//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWMechanicalSwitchVC: UIViewController {

    private let vm: DetailMechanicalSwitchVM = MWDetailMechanicalSwitchVM()

    @IBOutlet weak var mechanicalSwitchLabel: UILabel!
    @IBOutlet weak var startSwitch: UIButton!
    @IBOutlet weak var stopSwitch: UIButton!

}

extension MWMechanicalSwitchVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWMechanicalSwitchVC: DetailMechanicalSwitchVMDelegate {

    func refreshView() {
        mechanicalSwitchLabel.text = vm.switchState
        startSwitch.isEnabled = !vm.isMonitoring
        stopSwitch.isEnabled = vm.isMonitoring
    }
}

// MARK: - Intents

extension MWMechanicalSwitchVC {

    @IBAction func startSwitchNotifyPressed(_ sender: Any) {
        vm.userStoppedMonitoringSwitch()
    }

    @IBAction func stopSwitchNotifyPressed(_ sender: Any) {
        vm.userStoppedMonitoringSwitch()
    }
}
