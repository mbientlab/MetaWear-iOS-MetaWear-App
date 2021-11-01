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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(forInfoPanels ? "Device Identity and Status" : "Sensors")
        .measureWidth(key: ScreenWidthKey.self)
        .onPreferenceChange(ScreenWidthKey.self, perform: determineColumnCount(for:))
    }

    var layout: some View {
        ForEach(columns, id:\.self) { column in

            VStack(alignment: .leading, spacing: .cardGridSpacing) {
                ForEach(getDetailGroups(for: column)) { group in

                    BlockBuilder(group: group, namespace: details)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(group.title)
                        .compositingGroup()
                        .id(group)
                        .matchedGeometryEffect(id: group, in: details)
                }
            }
            .accessibilityElement(children: .contain)
        }
        .frame(width: .detailBlockWidth, alignment: .top)
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
        let columnCount = columns.endIndex

        if forInfoPanels, let predefinedLayout = HeaderLayouts(rawValue: columnCount) {
            let supportedGroups = Set(vc.sortedVisibleGroups)
            return predefinedLayout.layout(for: column).filter { supportedGroups.contains($0) }
        } else {
            return strideAcrossDetailGroups(columnCount, toBuild: column)
        }
    }

    func strideAcrossDetailGroups(_ columnCount: Int, toBuild column: Int) -> [DetailGroup] {
        let items = vc.sortedVisibleGroups.filter { HeaderLayouts.infoGroups.contains($0) == forInfoPanels }
        let itemCount = items.endIndex

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

    static let infoGroups: Set<DetailGroup> = [.headerInfoAndState, .identifiers, .signal, .reset, .ibeacon, .logs]

    func layout(for column: Int) -> [DetailGroup] {
        return layouts[column]
    }

    var layouts: [[DetailGroup]] {
        switch self {
            case .oneColumns: return [
                [.headerInfoAndState, .identifiers, .ibeacon, .reset, .signal, .logs]
            ]

            case .twoColumns: return [
                [.headerInfoAndState, .identifiers],
                [.signal, .logs, .ibeacon, .reset]
            ]

            case .threeColumns: return [
                [.headerInfoAndState, .reset, .ibeacon],
                [.identifiers],
                [.signal, .logs]
            ]
        }
    }
}
