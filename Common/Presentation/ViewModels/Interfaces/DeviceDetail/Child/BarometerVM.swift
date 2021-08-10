//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol BarometerVM: AnyObject, DetailConfiguring {

    var delegate: MWBarometerVMDelegate? { get set }

    var isStreaming: Bool { get }

    // Sensor settings
    var barometerStandbyTimeSelected: BarometerStandbyTime { get }
    var barometerIIRFilterSelected: BarometerIIRFilter { get }
    var barometerOversamplingSelected: BarometerOversampling { get }
    var barometerStandbyTimeOptions: [BarometerStandbyTime] { get }
    var barometerIIRTimeOptions: [BarometerIIRFilter] { get }
    var barometerOversamplingOption: [BarometerOversampling] { get }

    func userRequestedStreamStart()
    func userRequestedStreamStop()

    func userSetStandbyTime(_ newValue: BarometerStandbyTime)
    func userSetIIRFilter(_ newValue: BarometerIIRFilter)
    func userSetOversampling(_ newValue: BarometerOversampling)
}

public protocol MWBarometerVMDelegate {
    func refreshView()
}
