//
//  DeviceTableViewCellVM.swift
//  DeviceTableViewCellVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit
import MetaWear

class DeviceTableViewCell: UITableViewCell {

    static let identifier = "DeviceTableViewCell"

    var vm: ScannedDeviceCellVM? = nil

    override func prepareForReuse() {
        super.prepareForReuse()
        vm?.cancelSubscriptions()
    }
}

extension DeviceTableViewCell: ScannedDeviceCell {

    func refreshView() {
        guard let vm = vm else { return }
        (viewWithTag(1) as! UILabel).text = vm.uuid
        (viewWithTag(2) as! UILabel).text = vm.rssi
        (viewWithTag(2) as! UILabel).isHidden = !vm.showRSSI
        (viewWithTag(3) as! UILabel).isHidden = !vm.isConnected
        (viewWithTag(4) as! UILabel).text = vm.name
        (viewWithTag(5) as! UIImageView).image = UIImage(named: vm.signalImage)
    }
}
