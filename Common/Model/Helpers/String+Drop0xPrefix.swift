//
//  String+Drop0xPrefix.swift
//  String+Drop0xPrefix
//
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

extension String {
    var drop0xPrefix: String {
        return hasPrefix("0x") ? String(dropFirst(2)) : self
    }
}
