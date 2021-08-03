//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit

class MWAccelerometerVC: UIViewController {

    private let vm: DetailAccelerometerVM = MWDetailAccelerometerVM()

    @IBOutlet weak var accelerometerBMI160Scale: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160Frequency: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160StartStream: UIButton!
    @IBOutlet weak var accelerometerBMI160StopStream: UIButton!
    @IBOutlet weak var accelerometerBMI160StartLog: UIButton!
    @IBOutlet weak var accelerometerBMI160StopLog: UIButton!
    @IBOutlet weak var accelerometerBMI160Graph: APLGraphView!
    @IBOutlet weak var accelerometerBMI160StartOrient: UIButton!
    @IBOutlet weak var accelerometerBMI160StopOrient: UIButton!
    @IBOutlet weak var accelerometerBMI160OrientLabel: UILabel!
    @IBOutlet weak var accelerometerBMI160StartStep: UIButton!
    @IBOutlet weak var accelerometerBMI160StopStep: UIButton!
    @IBOutlet weak var accelerometerBMI160StepLabel: UILabel!
}

extension MWAccelerometerVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
    }
}

extension MWAccelerometerVC: DetailAccelerometerVMDelegate {

    func refreshView() {

    }

    func presentAlert(title: String, message: String) {
        MetaWearApp.presentAlert(in: self, title: title, message: message)
    }

}

// MARK: - Intents

extension MWAccelerometerVC {

    @IBAction func accelerometerBMI160StartStreamPressed(_ sender: Any) {
        vm.userRequestedStartStreaming()
    }

    @IBAction func accelerometerBMI160StopStreamPressed(_ sender: Any) {
        vm.userRequestedStopStreaming()
    }

    @IBAction func accelerometerBMI160StartLogPressed(_ sender: Any) {
        vm.userRequestedStartLogging()
    }

    @IBAction func accelerometerBMI160StopLogPressed(_ sender: Any) {
        vm.userRequestedStopAndDownloadLog()
    }

    @IBAction func accelerometerBMI160EmailDataPressed(_ sender: Any) {
        vm.userRequestedDatExport()
    }

    @IBAction func accelerometerBMI160StartOrientPressed(_ sender: Any) {
        vm.userRequestedStartOrienting()
    }

    @IBAction func accelerometerBMI160StopOrientPressed(_ sender: Any) {
        vm.userRequestedStopOrienting()
    }

    @IBAction func accelerometerBMI160StartStepPressed(_ sender: Any) {
        vm.userRequestedStartStepping()
    }

    @IBAction func accelerometerBMI160StopStepPressed(_ sender: Any) {
        vm.userRequestedStopStepping()
    }
}

