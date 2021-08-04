//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWAccelerometerSVC: MWDetailAccelerometerVM, DetailAccelerometerVMDelegate, ObservableObject, GraphDelegate {

    override init() {
        super.init()
        self.delegate = self
    }

    weak var graph: UIView? = nil
//    weak var graph: APLGraphView? = nil

    var dataPoints: Int { max(0, self.accelerometerBMI160Data.endIndex - 1) }

    func graphScaleLabel(_ scale: AccelerometerGraphScale) -> String {
        "\(scale.fullScale)"
    }

    func refreshView() {
        self.objectWillChange.send()
    }

    func refreshGraphScale() {
//        graph?.fullScale = Float(graphScaleSelected.fullScale)
    }

    func addGraphPoint(x: Double, y: Double, z: Double) {

//        graph?.addX(x, y: y, z: z)

        let wasEmpty = accelerometerBMI160Data.isEmpty

        DispatchQueue.main.async { [weak self] in
            if wasEmpty { self?.refreshView() } // So "canExportData" will refresh.
        }
    }

    func willStartNewGraphStream() {
        // Do nothing
    }
}
