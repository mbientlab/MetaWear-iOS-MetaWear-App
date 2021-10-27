//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct StatsBlock: View {

    var colors: [Color]
    @ObservedObject var vm: StatsVM

    var body: some View {
        VStack(spacing: .standardVStackSpacing) {
            LabeledItem(
                label: "Points",
                content: Text(String(vm.count)).fontSmall()
            )

            ForEach(vm.stats.kind.indexedChannelLabels, id: \.index) { (index, label) in
                LabeledColorKeyedItem(
                    color: colors[index],
                    label: label,
                    content: StatsRow(
                        min: vm.stats.mins[index],
                        max: vm.stats.maxs[index]
                    ),
                    alignment: .center
                )
            }
        }
    }

    struct StatsRow: View {

        var min: Float
        var max: Float

        var body: some View {
            HStack {
                Pair(label: "Min", stat: min)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Pair(label: "Max", stat: max)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    struct Pair: View {

        let label: String
        let stat: Float

        var body: some View {
            HStack {
                Text(label)
                    .fontVerySmall(lowercaseSmallCaps: true)
                    .foregroundColor(.mwSecondary)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)

                Text(String(format: "%1.1f", clipOutMax()))
                    .fontSmall(monospacedDigit: true)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
        }

        func clipOutMax() -> Float {
            guard stat != Float.greatestFiniteMagnitude || stat != Float.leastNormalMagnitude
            else { return 0 }
            return stat
        }
    }

    /// Avoids unnecessary SwiftUI dimensions recalculation
    struct LayoutPerformanceWorkaround: View {

        let colors: [Color]
        let vm: StatsVM

        var body: some View {
            VStack(spacing: .standardVStackSpacing) {
                LabeledItem(
                    label: "Points",
                    content: Text(String(vm.count)).fontSmall()
                )

                ForEach(vm.stats.kind.indexedChannelLabels, id: \.index) { (index, label) in
                    LabeledColorKeyedItem(
                        color: colors[index],
                        label: label,
                        content: StatsRow(
                            min: 0,
                            max: 0
                        ),
                        alignment: .center
                    )
                }
            }
            .hidden()
            .overlay(StatsBlock(colors: colors, vm: vm))
        }
    }
}
