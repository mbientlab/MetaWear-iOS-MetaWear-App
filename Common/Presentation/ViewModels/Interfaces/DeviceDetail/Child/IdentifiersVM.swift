//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol IdentifiersVM: AnyObject, DetailConfiguring {

    var delegate: IdentifiersVMDelegate? { get set }

    var manufacturer: String { get }
    var modelNumber: String { get }
    var serialNumber: String { get }
    var harwareRevision: String { get }

}

public protocol IdentifiersVMDelegate: AnyObject {
    func refreshView()
}
