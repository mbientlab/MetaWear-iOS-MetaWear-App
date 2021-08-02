//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWTemperatureVC: UIViewController {

    private let vm: DetailTemperatureVM = MWDetailTemperatureVM()

    @IBOutlet weak var tempChannelSelector: UISegmentedControl!
    @IBOutlet weak var channelTypeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var readPinLabel: UILabel!
    @IBOutlet weak var readPinTextField: UITextField!
    @IBOutlet weak var enablePinLabel: UILabel!
    @IBOutlet weak var enablePinTextField: UITextField!

}

extension MWTemperatureVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWTemperatureVC: DetailTemperatureVMDelegate {

    func resetView() {
        tempChannelSelector.removeAllSegments()
        zip(vm.channels, vm.channels.indices).forEach { (segment, index) in
            tempChannelSelector.insertSegment(withTitle: segment, at: index, animated: false)
        }

        refreshView()
    }

    func refreshView() {
        tempChannelSelector.selectedSegmentIndex = vm.selectedChannelIndex

        if vm.showPinDetail {
            self.readPinLabel.isHidden = false
            self.readPinTextField.isHidden = false
            self.enablePinLabel.isHidden = false
            self.enablePinTextField.isHidden = false
        } else {
            self.readPinLabel.isHidden = true
            self.readPinTextField.isHidden = true
            self.enablePinLabel.isHidden = true
            self.enablePinTextField.isHidden = true
        }

        temperatureLabel.text = vm.temperature
    }
}

// MARK: - Intents

extension MWTemperatureVC {

    @IBAction func tempChannelSelectorPressed(_ sender: Any) {
        vm.selectChannel(at: tempChannelSelector.selectedSegmentIndex)
    }

    @IBAction func readTemperaturePressed(_ sender: Any) {
        vm.readTemperature()
    }
}
