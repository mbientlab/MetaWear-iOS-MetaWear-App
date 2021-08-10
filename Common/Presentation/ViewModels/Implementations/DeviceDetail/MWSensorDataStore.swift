//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp

public class MWSensorDataStore {

    public var logged: [TimeIdentifiedDataPoint] = []
    public var stream: [TimeIdentifiedDataPoint] = []

    public private(set) var loggedKind: DataPointKind = .cartesianXYZ
    public private(set) var streamKind: DataPointKind = .cartesianXYZ

    public var loggedCount: Int { logged.countedByEndIndex() }
    public var streamCount: Int { stream.countedByEndIndex() }
}

public extension MWSensorDataStore {

    func getLoggedStats() -> MWDataStreamStats {
        .init(kind: loggedKind, data: logged)
    }

    func getStreamedStats() -> MWDataStreamStats {
        .init(kind: streamKind, data: stream)
    }

    func clearLogged(newKind: DataPointKind) {
        logged = []
        loggedKind = newKind
    }

    func clearStreamed(newKind: DataPointKind) {
        stream = []
        streamKind = newKind
    }

    func makeLogData() -> Data {
        var data = Data()

        let header = loggedKind.makeCSVHeaderLine()
        data.append(header.data(using: String.Encoding.utf8)!)

        for dataElement in logged {
            let csvString = loggedKind.csvFormattingMethod(dataElement)
            data.append(csvString.data(using: String.Encoding.utf8)!)
        }

        return data
    }

    func makeStreamData() -> Data {
        var data = Data()

        let header = streamKind.makeCSVHeaderLine()
        data.append(header.data(using: String.Encoding.utf8)!)

        for dataElement in stream {
            let csvString = streamKind.csvFormattingMethod(dataElement)
            data.append(csvString.data(using: String.Encoding.utf8)!)
        }

        return data
    }
}
