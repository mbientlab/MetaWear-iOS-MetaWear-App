//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class MWAccelerometerSVC: MWDetailAccelerometerVM, DetailAccelerometerVMDelegate, ObservableObject, GraphDelegate {

    override init() {
        super.init()
        self.delegate = self
    }

    weak var graph: APLGraphView? = nil

    var canExportData: Bool {
        !accelerometerBMI160Data.isEmpty
    }

    func graphScaleLabel(_ scale: AccelerometerGraphScale) -> String {
        "± \(scale.fullScale)"
    }

    func refreshView() {
        self.objectWillChange.send()
    }

    func refreshGraphScale() {
        graph?.fullScale = Float(graphScaleSelected.fullScale)
    }

    func addGraphPoint(x: Double, y: Double, z: Double) {
        graph?.addX(x, y: y, z: z)
    }

    func willStartNewGraphStream() {
        // Do nothing
    }
}
