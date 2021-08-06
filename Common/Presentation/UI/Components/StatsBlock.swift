//  Created by Ryan on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct StatsBlock: View {

    var stats: MWDataStreamStats
    var count: Int

    var body: some View {
        LabeledItem(
            label: "Min",
            content: mins,
            alignment: .center
        )

        LabeledItem(
            label: "Max",
            content: maxs,
            alignment: .center
        )

        LabeledItem(
            label: "Points",
            content: Text(String(count))
        )
    }

    private var mins: some View {
        GeometryReader { geo in
            HStack {
                Pair(label: "X", stat: stats.xMin)
                    .frame(width: geo.size.width / 3)

                Pair(label: "Y", stat: stats.yMin)
                    .frame(width: geo.size.width / 3)

                Pair(label: "Z", stat: stats.zMin)
                    .frame(width: geo.size.width / 3)

            }
        }
    }

    private var maxs: some View {
        GeometryReader { geo in
            HStack {
                Pair(label: "X", stat: stats.xMax)
                    .frame(width: geo.size.width / 3)

                Pair(label: "Y", stat: stats.yMax)
                    .frame(width: geo.size.width / 3)

                Pair(label: "Z", stat: stats.zMax)
                    .frame(width: geo.size.width / 3)
            }
        }
    }

    struct Pair: View {
        let label: String
        let stat: Float

        var body: some View {
            HStack {
                Text(label)
                    .font(.caption2.lowercaseSmallCaps())
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)

                Text(String(format: "%1.1f", stat))
                    .font(.caption.monospacedDigit())
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}
