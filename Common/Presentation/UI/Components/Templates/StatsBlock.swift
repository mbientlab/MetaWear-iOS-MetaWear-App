//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct StatsBlock: View {

    var colors: [Color]
    var stats: MWDataStreamStats
    var count: Int

    var body: some View {

        ForEach(stats.kind.indexedChannelLabels, id: \.index) { (index, label) in
            LabeledColorKeyedItem(
                color: colors[index],
                label: label,
                content: StatsRow(
                    min: stats.mins[index],
                    max: stats.maxs[index]
                ),
                alignment: .center
            )
        }

        LabeledItem(
            label: "Points",
            content: Text(String(count))
        )
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
                    .foregroundColor(.secondary)
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
}
