//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import BoltsSwift
import iOSDFULibrary
import Combine

public class MWSignalsStore: ObservableObject {

    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

    /// Tracks all streaming events (even for other devices).
    private var streamingEvents: Set<OpaquePointer> = []
    private var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    public private(set) var loggers: [String: OpaquePointer] = [:]

    private let queue = DispatchQueue(label: "LogUpdates", qos: .utility)
    private let timer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()
    private var updates: Set<AnyCancellable> = []
    @Published var logSize = ""

    private lazy var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.allowsFloats = false
        #if os(macOS)
        f.hasThousandSeparators = true
        #else
        f.groupingSeparator = ","
        f.groupingSize = 3
        f.usesGroupingSeparator = true
        #endif
        f.generatesDecimalNumbers = false
        f.numberStyle = NumberFormatter.Style.decimal
        return f
    }()

}

extension MWSignalsStore: SignalReferenceStoreSetup {

    public func setup(_ parent: MWDeviceDetailsCoordinator, _ device: MetaWear) {
        self.parent = parent
        self.device = device

        timer.sink { [weak self] _ in
            guard let self = self else { return }
            self.getLogSize()
        }.store(in: &updates)
    }

    public func completeAllStreamingCleanups() {
        streamingCleanup.forEach { $0.value() }
        streamingCleanup.removeAll()
    }

    public func removeAllLogs() {
        loggers = [:]
    }
}

extension MWSignalsStore: SignalReferenceStore {

    public func getLogSize() {
        guard let device = device else { return }
        guard device.isConnectedAndSetup, device.peripheral.state == .connected else { return }
        mbl_mw_logging_get_length_data_signal(device.board).read().continueWith(.mainThread) { [weak self] in
            guard let result = $0.result else { return }
            let number: UInt32 = result.valueAs()
            guard let self = self else { return }
            self.logSize = self.formatter.string(from: .init(value: number)) ?? ""
        }
    }

    public func clearLog() {
        guard let board = device?.board else { return }
        mbl_mw_logging_clear_entries(board)
        getLogSize()
        loggers = [:]
        objectWillChange.send()
    }

    public func stopLogging() {
        guard let board = device?.board else { return }
        mbl_mw_logging_stop(board)
        objectWillChange.send()
        parent?.delegate?.reloadAllCells()
    }

    public func startLogging() {
        guard let board = device?.board else { return }
        mbl_mw_logging_start(board, 0)
        objectWillChange.send()
        parent?.delegate?.reloadAllCells()
    }

    public func storeStream(_ signal: OpaquePointer, cleanup: (() -> Void)? ) {
        streamingCleanup[signal] = cleanup ?? { mbl_mw_datasignal_unsubscribe(signal) }
    }

    public func removeStream(_ signal: OpaquePointer) {
        streamingCleanup.removeValue(forKey: signal)?()
    }

    public func addLog(_ log: String, _ pointer: OpaquePointer) {
        loggers[log] = pointer
    }

    @discardableResult
    public func removeLog(_ log: String) -> OpaquePointer? {

        loggers.removeValue(forKey: log)
    }

}
