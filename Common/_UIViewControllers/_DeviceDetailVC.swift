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
    private var exportController: UIDocumentInteractionController!

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

}

// MARK: - Update for Model Changes

extension MWDeviceDetailTableVC: DeviceDetailsCoordinatorDelegate {

    func presentFileExportDialog(fileURL: URL, saveErrorTitle: String, saveErrorMessage: String) {
        self.exportController = UIDocumentInteractionController(url: fileURL)
        if !self.exportController.presentOptionsMenu(from: view.bounds, in: view, animated: true) {
//            presentAlert(in: self, title: saveErrorTitle, message: saveErrorMessage)
        }
    }


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
