//
//  DetailConfiguring.swift
//  DetailConfiguring
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

/// Shortcut to kick off tasks in VM after initialization, connect up objects.
public protocol DetailConfiguring {
    func configure(parent: DeviceDetailsCoordinator, device: MetaWear)
    func start()
}
