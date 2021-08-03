//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWDetailSignalStrengthVC: UIViewController {

    private let vm: DetailSignalStrengthVM = MWDetailSignalStrengthVM()

    @IBOutlet weak var rssiLevelLabel: UILabel!
    @IBOutlet weak var txPowerSelector: UISegmentedControl!

}

extension MWDetailSignalStrengthVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWDetailSignalStrengthVC: DetailSignalStrengthVMDelegate {

    func refreshView() {
        self.rssiLevelLabel.text = vm.rssiLevel
        self.txPowerSelector.selectedSegmentIndex = vm.chosenPowerLevelIndex
    }
}

// MARK: - Intents

extension MWDetailSignalStrengthVC {

    @IBAction func readRSSIPressed(_ sender: Any) {
        vm.userRequestsRSSI()
    }

    @IBAction func txPowerChanged(_ sender: Any) {
        vm.userChangedTransmissionPower(toIndex: txPowerSelector.selectedSegmentIndex)
    }

}
