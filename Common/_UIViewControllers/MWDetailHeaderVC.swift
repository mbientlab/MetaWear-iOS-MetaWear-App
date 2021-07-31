//
//  MWDetailHeaderVC.swift
//  MWDetailHeaderVC
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWDetailHeaderVC: UIViewController {

    private let vm: DetailHeaderVM = MWDetailHeaderVM()

    @IBOutlet weak var connectionSwitch: UISwitch!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var setNameButton: UIButton!

}

// MARK: - Lifecycle

extension MWDetailHeaderVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
        nameTextField.delegate = self
    }
}

// MARK: - Update for Model Changes

extension MWDetailHeaderVC: DetailHeaderVMDelegate {

    func refreshView() {
        nameTextField.text = vm.deviceName
        connectionStateLabel.text = vm.connectionState
        connectionSwitch.isOn = vm.connectionIsOn
    }
}

// MARK: - Intents

extension MWDetailHeaderVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.setNameButton.isEnabled = true
        return vm.didUserTypeValidDeviceName(string, range: range, fullString: textField.text ?? "")
    }

    /// called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension MWDetailHeaderVC {

    @IBAction func setNamePressed(_ sender: Any) {
        nameTextField.resignFirstResponder()
        guard let name = nameTextField.text else { return }
        vm.userUpdatedName(to: name)
        setNameButton.isEnabled = false
    }

    @IBAction func connectionSwitchPressed(_ sender: Any) {
        vm.userSetConnection(to: connectionSwitch.isOn)
    }
}
