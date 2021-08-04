//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

#if os(iOS)
import UIKit
#endif


class MWDeviceDetailScreenSVC: MWDeviceDetailsCoordinator, ObservableObject {

    private(set) var visibleGroupsDict: [DetailGroup:Bool]  = [:]
#if os(iOS)
    private var exportController: UIDocumentInteractionController? = nil
#endif
}

extension MWDeviceDetailScreenSVC: DeviceDetailsCoordinatorDelegate {

    func hideAndReloadAllCells() {
        visibleGroupsDict = [:]
        self.objectWillChange.send()
    }

    func reloadAllCells() {

        self.objectWillChange.send()
    }

    func changeVisibility(of group: DetailGroup, shouldShow: Bool) {
        visibleGroupsDict[group] = shouldShow
    }

    func presentFileExportDialog(fileURL: URL,
                                 saveErrorTitle: String,
                                 saveErrorMessage: String) {
#if os(iOS)
        guard let view = UIApplication.firstKeyWindow()?.rootViewController?.view
        else { return }

        self.exportController = UIDocumentInteractionController(url: fileURL)

        if self.exportController?.presentOptionsMenu(from: view.bounds, in: view, animated: true) == false {
            self.alerts.presentAlert(title: saveErrorTitle,
                                        message: saveErrorMessage)
        }
#endif
    }

}
