//
//  Sort+RawRepresentable.swift
//  Sort+RawRepresentable
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public extension Collection where Element: RawRepresentable, Element.RawValue: Comparable {
    func sortedByRawValue() -> [Element] {
        sorted { $0.rawValue < $1.rawValue }
    }
}

public protocol IntSortOrder {
    var sortOrder: Int { get }
}

public extension Collection where Element: IntSortOrder {
    func sortedAsSpecified() -> [Element] {
        sorted { $0.sortOrder < $1.sortOrder }
    }
}
