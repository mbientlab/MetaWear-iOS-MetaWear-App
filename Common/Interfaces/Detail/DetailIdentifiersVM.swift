//
//  MWDetailHeaderVM.swift
//  MWDetailHeaderVM
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol DetailIdentifiersVM: AnyObject, DetailConfiguring {

    var delegate: DetailIdentifiersVMDelegate? { get set }
    var manufacturer: String { get }
    var modelNumber: String { get }
    var serialNumber: String { get }
    var harwareRevision: String { get }

    /// Show relevant information
    func start()

}

public protocol DetailIdentifiersVMDelegate: AnyObject {
    func refreshView()
}
