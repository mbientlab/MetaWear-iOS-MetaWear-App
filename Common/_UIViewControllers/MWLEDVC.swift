//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWLEDVC: UIViewController {

    private let vm: DetailLEDVM = MWDetailLEDVM()

}

extension MWLEDVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWLEDVC: DetailLEDVMDelegate {

    func refreshView() {

    }
}

// MARK: - Intents

extension MWLEDVC {

    @IBAction func turn(onGreenLEDPressed sender: Any) {
        vm.turnOnGreen()
    }

    @IBAction func flashGreenLEDPressed(_ sender: Any) {
        vm.flashGreen()
    }

    @IBAction func turn(onRedLEDPressed sender: Any) {
        vm.turnOnRed()
    }

    @IBAction func flashRedLEDPressed(_ sender: Any) {
        vm.flashRed()
    }

    @IBAction func turn(onBlueLEDPressed sender: Any) {
        vm.turnOnBlue()
    }

    @IBAction func flashBlueLEDPressed(_ sender: Any) {
        vm.flashBlue()
    }

    @IBAction func turnOffLEDPressed(_ sender: Any) {
        vm.turnOffLEDs()
    }
}

