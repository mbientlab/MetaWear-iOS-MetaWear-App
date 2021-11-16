//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public class StatsVM: ObservableObject {

    @Published public var stats: MWDataStreamStats
    @Published public var count: Int

    public init(_ stats: MWDataStreamStats, _ count: Int) {
        self.stats = stats
        self.count = count
    }

    func addNewPoints(_ data: ArraySlice<TimeIdentifiedDataPoint>, kind: DataPointKind) {
        guard stats.kind == kind else {
            stats = .zero(for: kind)
            count = 0
            addNewPoints(data, kind: kind)
            return
        }

        var newStats = stats

        for timepoint in data {
            for series in timepoint.values.indices {
                let value = timepoint.values[series]
                if value > newStats.maxs[series] {
                    newStats.maxs[series] = value
                }
                if value < newStats.mins[series] {
                    newStats.mins[series] = value
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.stats = newStats
            self?.count += (data.endIndex - data.startIndex)
        }
    }
}
