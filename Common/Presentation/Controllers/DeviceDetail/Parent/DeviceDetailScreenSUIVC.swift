//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
#if os(iOS)
import UIKit
#endif

/// Wraps imperative calls for SwiftUI. Also supports UIKit storyboard entry.
///
public class DeviceDetailScreenSUIVC: MWDeviceDetailsCoordinator, ObservableObject {

    /// State for available capabilities
    private(set) var visibleGroupsDict: [DetailGroup:Bool]  = [:]

    /// For layout, capabilities with the Header removed
    public var sortedVisibleGroups: [DetailGroup] {
        visibleGroupsDict
            .filter { $0.value && $0.key != .headerInfoAndState }
            .keys
            .sortedAsSpecified()
    }

    /// For SwiftUI without a storyboard segue
    public convenience init(device: MetaWear?, vms: DetailVMContainer) {
        self.init(vms: vms)
        guard let device = device else { return }
        setDevice(device)
    }

    /// For UIKit with a storyboard segue to set device
    public override init(vms: DetailVMContainer) {
        super.init(vms: vms)
        self.delegate = self
    }

#if os(iOS)
    private var exportController: UIDocumentInteractionController? = nil
#endif

}

// MARK: - Delegate

extension DeviceDetailScreenSUIVC: DeviceDetailsCoordinatorDelegate {

    public func hideAndReloadAllCells() {
        visibleGroupsDict = [:]
        self.objectWillChange.send()
    }

    public func reloadAllCells() {
        self.objectWillChange.send()
    }

    public func changeVisibility(of group: DetailGroup, shouldShow: Bool) {
        visibleGroupsDict[group] = shouldShow
    }

#if os(iOS)

    public func presentFileExportDialog(fileURL: URL,
                                        saveErrorTitle: String,
                                        saveErrorMessage: String) {
        guard let view = UIApplication.firstKeyWindow()?.rootViewController?.view else { return }

        self.exportController = UIDocumentInteractionController(url: fileURL)

        if self.exportController?.presentOptionsMenu(from: view.bounds, in: view, animated: true) == false {
            self.alerts.presentAlert(title: saveErrorTitle,
                                     message: saveErrorMessage)
        }
    }

#elseif os(macOS)

    public func presentFileExportDialog(fileURL: URL,
                                        saveErrorTitle: String,
                                        saveErrorMessage: String) {

        guard let window = NSApp.keyWindow else { return }
        let panel = configureSavePanel(prompt: "Save MetaWear Data", name: fileURL.lastPathComponent)

        panel.beginSheetModal(for: window) { [weak self] (response) in
            guard response == .OK,
                  let url = panel.url else { return }

            do {
                try FileManager.default.copyItem(at: fileURL, to: url)
            } catch let error {
                NSLog(error.localizedDescription)
                self?.alerts.presentAlert(title: saveErrorTitle, message: saveErrorMessage)
            }
        }

    }

    private func configureSavePanel(prompt: String, name: String) -> NSSavePanel {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.showsHiddenFiles = true
        panel.canSelectHiddenExtension = true
        panel.prompt = prompt
        panel.nameFieldStringValue = name
        return panel
    }

#endif
}

