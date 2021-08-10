//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol AmbientLightVM: AnyObject, DetailConfiguring {

    var delegate: AmbientLightVMDelegate? { get set }

    var isStreaming: Bool { get }

    // Sensor settings
    var gainOptions: [AmbientLightGain] { get }
    var gainSelected: AmbientLightGain { get }
    var integrationTimeOptions: [AmbientLightTR329IntegrationTime] { get }
    var integrationTimeSelected: AmbientLightTR329IntegrationTime { get }
    var measurementRateOptions: [AmbientLightTR329MeasurementRate] { get }
    var measurementRateSelected: AmbientLightTR329MeasurementRate { get }

    func userRequestedStreamStart()
    func userRequestedStreamStop()

    func userSetGain(_ newValue: AmbientLightGain)
    func userSetIntegrationTime(_ newValue: AmbientLightTR329IntegrationTime)
    func userSetMeasurementRate(_ newValue: AmbientLightTR329MeasurementRate)
}

public protocol AmbientLightVMDelegate: AnyObject {
    func refreshView()
}

