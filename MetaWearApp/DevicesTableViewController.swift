//
//  DeviceTableViewCellVM.swift
//  DeviceTableViewCellVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit
import MetaWear
import MetaWearCpp
import MBProgressHUD
import iOSDFULibrary

fileprivate let scanner = MetaWearScanner()

class DevicesTableViewController: UITableViewController {

    var vm: DevicesScanningVM!

    @IBOutlet weak var scanningSwitch: UISwitch!
    @IBOutlet weak var metaBootSwitch: UISwitch!
    @IBOutlet weak var activity: UIActivityIndicatorView!
}

// MARK: - Lifecycle

extension DevicesTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = MWDevicesScanningVM()
        vm.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        vm.startScanning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        vm.stopScanning()
    }

}

// MARK: - Updates

extension DevicesTableViewController: DevicesScanningCoordinatorDelegate {

    func didAddDiscoveredDevice(at index: Int) {
        let indexPath = IndexPath(row: index, section: 1)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func refreshScanningStatus() {
        scanningSwitch.isOn = vm.isScanning

        if vm.isScanning {
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
    }

    func refreshMetaBootStatus() {
        metaBootSwitch.isOn = vm.useMetaBootMode
    }

    func refreshConnectedDevices() {
        tableView.reloadData()
    }

}

// MARK: - UITableView

extension DevicesTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return vm.connectedDevices.count
            case 1: return vm.discoveredDevices.count
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.identifier, for: indexPath) as! DeviceTableViewCell

        cell.vm = MWScannedDeviceCellVM()

        let setDevice = indexPath.section == 0
        if setDevice {
            cell.vm?.configure(cell, for: vm.connectedDevices[indexPath.row])
        } else {
            cell.vm?.configure(cell, for: vm.discoveredDevices[indexPath.row])
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "Connected Devices"
            case 1: return "Devices"
            default: return "Error"
        }
    }
}

// MARK: - Intents

extension DevicesTableViewController {


    @IBAction func scanningSwitchPressed(_ sender: UISwitch) {
        vm.userChangedScanningState(to: sender.isOn)
    }
    
    @IBAction func metaBootSwitchPressed(_ sender: UISwitch) {
        vm.userChangedUseMetaBootMode(to: sender.isOn)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var device: MetaWear? = nil
        switch indexPath.section {
            case 0: device = vm.connectedDevices[indexPath.row]
            case 1: device = vm.discoveredDevices[indexPath.row].device
            default: break
        }
        guard let device = device else { return }
        performSegue(withIdentifier: "DeviceDetails", sender: device)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DeviceDetailScreenUIKitContainer
        destination.setDevice(device: sender as! MetaWear)
    }
}
