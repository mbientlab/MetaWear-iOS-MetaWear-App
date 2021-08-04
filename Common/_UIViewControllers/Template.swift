//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class VC: UIViewController {

    private let vm: VM = .init()

    @IBOutlet weak var tempChannelSelector: UISegmentedControl!

}

extension VC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension VC: MWVMDelegate {

    func refreshView() {

    }
}

// MARK: - Intents

extension VC {

}

class VM {
    var delegate: MWVMDelegate? = nil
}

protocol MWVMDelegate {

}
