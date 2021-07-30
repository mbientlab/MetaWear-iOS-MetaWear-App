//
//  String+Drop0xPrefix.swift
//  String+Drop0xPrefix
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

extension String {
    var drop0xPrefix: String {
        return hasPrefix("0x") ? String(dropFirst(2)) : self
    }
}
