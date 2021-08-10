//  Created by Ryan Ferrell on 8/5/21.
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
                ForEach(stats.kind.indexedChannelLabels, id: \.index) { (index, label) in
                    Pair(label: label, stat: stats.mins[index])
                }.frame(width: geo.size.width / CGFloat(stats.kind.channelCount))
            }
        }
    }

    private var maxs: some View {
        GeometryReader { geo in
            HStack {
                ForEach(stats.kind.indexedChannelLabels, id: \.index) { (index, label) in
                    Pair(label: label, stat: stats.mins[index])
                }.frame(width: geo.size.width / CGFloat(stats.kind.channelCount))
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

                Text(String(format: "%1.1f", stat))
                    .fontSmall(monospacedDigit: true)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}
