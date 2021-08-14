//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct GridLayout: View {

    var details: Namespace.ID
    var alignment: Alignment = .topLeading
    var forInfoPanels: Bool

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC

    @State private var columns: [Int] = [0]

    var body: some View {
        HStack(alignment: .top, spacing: .cardGridSpacing) {
            layout
        }
        .animation(.linear(duration: 0.2), value: columns)
        .animation(.linear(duration: 0.2), value: vc.sortedVisibleGroups)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .ignoresSafeArea()

        .measureWidth(key: ScreenWidthKey.self)
        .onPreferenceChange(ScreenWidthKey.self, perform: determineColumnCount(for:))
    }

    var layout: some View {
        ForEach(columns, id:\.self) { column in

            LazyVStack(alignment: .leading, spacing: .cardGridSpacing) {
                ForEach(getDetailGroups(for: column)) { group in

                    BlockBuilder(group: group, namespace: details)
                        .id(group)
                        .matchedGeometryEffect(id: group, in: details, properties: .position, anchor: .leading, isSource: forInfoPanels)
                }
            }

        }
        .frame(width: .detailBlockWidth)
    }
}

extension GridLayout {

    func determineColumnCount(for width: CGFloat) {
        let columnWidth = .detailBlockWidth + (.cardGridSpacing)
        let count = Int(width / columnWidth)
        let newColumnArray = count > 1 ? Array(0..<count) : [0]
        if columns.endIndex != newColumnArray.endIndex { columns = newColumnArray }
    }

    func getDetailGroups(for column: Int) -> [DetailGroup] {
        let columnCount = columns.countedByEndIndex()

        if forInfoPanels, let predefinedLayout = HeaderLayouts(rawValue: columnCount) {
            return predefinedLayout.layout(for: column).filter { vc.visibleGroupsDict[$0] == true }
        } else {
            return strideAcrossDetailGroups(columnCount, toBuild: column)
        }
    }

    func strideAcrossDetailGroups(_ columnCount: Int, toBuild column: Int) -> [DetailGroup] {
        let items = vc.sortedVisibleGroups.filter { $0.isInfo == forInfoPanels }
        let itemCount = items.countedByEndIndex()

        var columnItems: [DetailGroup] = []

        for index in stride(from: column, to: itemCount, by: columnCount) {
            columnItems.append(items[index])
        }

        return columnItems
    }

}

fileprivate struct ScreenWidthKey: WidthKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}


fileprivate enum HeaderLayouts: Int {
    case oneColumns = 1
    case twoColumns
    case threeColumns
    case fourColumns
    case fiveColumns
    case sixColumns
    case sevenColumns

    func layout(for column: Int) -> [DetailGroup] {
        return layouts[column]
    }

    var layouts: [[DetailGroup]] {
        switch self {
            case .oneColumns: return [
                [.headerInfoAndState, .identifiers, .battery, .firmware, .ibeacon, .reset, .signal]
            ]

            case .twoColumns: return [
                [.headerInfoAndState, .identifiers, .firmware],
                [.battery, .ibeacon, .reset, .signal]
            ]

            case .threeColumns: return [
                [.headerInfoAndState, .identifiers],
                [.firmware, .signal],
                [.battery, .ibeacon, .reset]
            ]

            case .fourColumns: return [
                [.headerInfoAndState, .battery],
                [.identifiers],
                [.firmware, .ibeacon],
                [.signal, .reset],
            ]

            case .fiveColumns: return [
                [.headerInfoAndState, .battery],
                [.identifiers],
                [.firmware],
                [.signal],
                [.ibeacon, .reset]
            ]

            case .sixColumns: return [
                [.headerInfoAndState],
                [.identifiers],
                [.firmware],
                [.signal],
                [.battery],
                [.ibeacon, .reset]
            ]

            case .sevenColumns: return [
                [.headerInfoAndState],
                [.identifiers],
                [.firmware],
                [.signal],
                [.battery],
                [.ibeacon],
                [.reset]
            ]
        }
    }
}
