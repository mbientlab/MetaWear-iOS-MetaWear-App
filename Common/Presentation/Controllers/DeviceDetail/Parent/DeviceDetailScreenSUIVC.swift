//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import Combine
#if os(iOS)
import UIKit
#endif

/// Wraps imperative calls for SwiftUI and (macOS) NSCollectionViewDiffableDataSource. Also supports UIKit storyboard entry.
///
public class DeviceDetailScreenSUIVC: MWDeviceDetailsCoordinator, ObservableObject {

    /// Present UI for available capabilities
    @Published public private(set) var sortedVisibleGroups: [DetailGroup] = [.headerInfoAndState]

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



}

// MARK: - Delegate

extension DeviceDetailScreenSUIVC: DeviceDetailsCoordinatorDelegate {

    public func show(groups: [DetailGroup]) {
        var newGroups = Set(sortedVisibleGroups)
        newGroups.formUnion(Set(groups))
        sortedVisibleGroups = newGroups.sortedAsSpecified()
    }

    public func hideAllCells() {
        sortedVisibleGroups = [.headerInfoAndState]
    }

    public func reloadAllCells() {
        /// Not implemented
        self.objectWillChange.send()
    }

    public func changeVisibility(of group: DetailGroup, shouldShow: Bool) {
        guard let index = sortedVisibleGroups.firstIndex(of: group) else { return }
        sortedVisibleGroups.remove(at: index)
    }
}

