//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol GraphObject: AnyObject {

    func addPointInAllSeries(_ point: [Float])
    func updateYScale(min: Double, max: Double, data: [[Float]])
    func clearData()

}
