//
//  DeviceDetailVC.swift
//  DeviceDetailVC
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import UIKit
import StaticDataTableViewController

/// TEMPORARY FOR REFACTORING PROGRESS
class MWDeviceDetailTableVC: StaticDataTableViewController {

    private let vc: DeviceDetailsCoordinator = MWDeviceDetailsCoordinator()

    @IBOutlet var allCells: [UITableViewCell]!
    @IBOutlet var infoAndStateCells: [UITableViewCell]!
}

// MARK: - Lifecycle

extension MWDeviceDetailTableVC {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vc.delegate = self
        vc.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vc.end()
    }
}

// MARK: - StaticDataTableViewController

extension MWDeviceDetailTableVC {

    override func showHeader(forSection section: Int, vissibleRows: Int) -> Bool {
        return vissibleRows != 0
    }

    override func showFooter(forSection section: Int, vissibleRows: Int) -> Bool {
        return vissibleRows != 0
    }

    #warning("BLOCKED ON observeValue(forKeyPath:")
}

// MARK: - Update for Model Changes

extension MWDeviceDetailTableVC: DeviceDetailsCoordinatorDelegate {

    func hideAndReloadAllCells() {
        cells(allCells, setHidden: true)
        reloadData(animated: false)
    }

    func reloadAllCells() {
        reloadData(animated: true)
    }

    func changeVisibility(of group: DetailGroup, shouldShow: Bool) {
        switch group {
            case .identifiers: fallthrough
            case .headerInfoAndState: cells(self.infoAndStateCells, setHidden: false)
            default: print("COMPLETE ENUM")
        }
    }
}

// MARK: - Intents

extension MWDeviceDetailTableVC {

}
