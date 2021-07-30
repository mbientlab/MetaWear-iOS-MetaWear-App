//
//  DeviceTableViewCell.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 7/26/18.
//  Copyright © 2018 MbientLab. All rights reserved.
//

import UIKit
import MetaWear

class DeviceTableViewCell: UITableViewCell {

    static let identifier = "DeviceTableViewCell"

    var vm: DeviceCellVM? = nil

    override func prepareForReuse() {
        super.prepareForReuse()
        vm?.cancelSubscriptions()
    }
}

extension DeviceTableViewCell: DeviceCell {

    func updateView() {
        guard let vm = vm else { return }
        (viewWithTag(1) as! UILabel).text = vm.uuid
        (viewWithTag(2) as! UILabel).text = vm.rssi
        (viewWithTag(3) as! UILabel).isHidden = !vm.isConnected
        (viewWithTag(4) as! UILabel).text = vm.name
        (viewWithTag(5) as! UIImageView).image = UIImage(named: vm.signalImage)
    }
}
