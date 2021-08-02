//
//  DetailSignalStrengthVM.swift
//  DetailSignalStrengthVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//


import Foundation

public protocol DetailSignalStrengthVM: AnyObject, DetailConfiguring {

    var delegate: DetailSignalStrengthVMDelegate? { get set }
    var rssiLevel: String { get }

    func start()
}

public protocol DetailSignalStrengthVMDelegate: AnyObject {
    func refreshView()
}
