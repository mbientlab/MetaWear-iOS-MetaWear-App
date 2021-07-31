//
//  DetailConfiguring.swift
//  DetailConfiguring
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

public protocol DetailConfiguring {
    func configure(parent: DeviceDetailsCoordinator, device: MetaWear)
}
