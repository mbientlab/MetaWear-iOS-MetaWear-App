//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol HumidityVM: AnyObject, DetailConfiguring {

    var delegate: HumidityVMDelegate? { get set }

    var humidity: Float { get }
    var humidityReadout: String { get }

    var isStreaming: Bool { get }
    var isOversampling: Bool { get }

    var oversamplingSelected: HumidityOversampling { get }
    var oversamplingOptions: [HumidityOversampling] { get }

    func userRequestedStreamingStart()
    func userRequestedStreamingStop()

}

public protocol HumidityVMDelegate: AnyObject {
    func refreshView()
}

