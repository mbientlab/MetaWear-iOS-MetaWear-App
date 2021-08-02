//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//


class MWDetailIdentifierVC: UIViewController {

    private let vm: DetailIdentifiersVM = MWDetailIdentifiersVM()

    @IBOutlet weak var mfgNameLabel: UILabel!
    @IBOutlet weak var serialNumLabel: UILabel!
    @IBOutlet weak var hwRevLabel: UILabel!
    @IBOutlet weak var fwRevLabel: UILabel!
    @IBOutlet weak var modelNumberLabel: UILabel!

}

extension MWDetailIdentifierVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWDetailIdentifierVC: DetailIdentifiersVMDelegate {

    func refreshView() {
        mfgNameLabel.text = vm.manufacturer
        serialNumLabel.text = vm.serialNumber
        hwRevLabel.text = vm.harwareRevision
        fwRevLabel.text = vm.firmwareRevision
        modelNumberLabel.text = vm.modelNumber
    }
}

// MARK: - Intents

extension MWDetailIdentifierVC {

        // Note
}
