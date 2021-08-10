//
//  Array+CountedByIndex.swift
//  Array+CountedByIndex
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public extension Array {

    func countedByEndIndex() -> Int {
        if self.isEmpty { return 0 }
        return endIndex > 1 ? endIndex : 1
    }
}
