//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class ToastPresentingLogDownloader {

    private(set) weak var parent: DeviceDetailsCoordinator?
    private(set) weak var delegate: LogDownloadHandlerDelegate?

}

extension ToastPresentingLogDownloader: LogDownloadHandler {

    public func reportProgress(board: OpaquePointer, to delegate: LogDownloadHandlerDelegate, parent: DeviceDetailsCoordinator?) {
        self.parent = parent
        self.delegate = delegate

        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remaining, total) in
            let _self: ToastPresentingLogDownloader = bridge(ptr: context!)
            _self.didReceiveProgressUpdate(remaining, total, _self)
        }

        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            let _self: ToastPresentingLogDownloader = bridge(ptr: context!)
            _self.delegate?.receivedUnknownEntry(context: _self.delegate, id: id, epoch: epoch, data: data, length: length)
        }
        handlers.received_unhandled_entry = { (context, data) in
            let _self: ToastPresentingLogDownloader = bridge(ptr: context!)
            _self.delegate?.receivedUnhandledEntry(context: _self.delegate, data: data)
        }

        mbl_mw_logging_download(board, 100, &handlers)
    }

}

public extension LogDownloadHandlerDelegate {

    func receivedUnknownEntry(context: LogDownloadHandlerDelegate?, id: UInt8, epoch: Int64, data: UnsafePointer<UInt8>?, length: UInt8) {
        NSLog("received_unknown_entry \(self) \(id) \(String(describing: data))")
    }

}


private extension ToastPresentingLogDownloader {

    func didReceiveProgressUpdate(_ remainingEntries: UInt32,
                                  _ totalEntries: UInt32,
                                  _ _self: ToastPresentingLogDownloader) {

        let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
        let safeProgress = progress.isNaN ? 0 : progress
        let percentage = Int(safeProgress * 100)

        guard safeProgress > 0  || totalEntries == 0 else { return }

        DispatchQueue.main.async {
            guard percentage != _self.parent?.toast.percentComplete else { return }
            _self.parent?.toast.updateProgress(percentage: percentage)
            guard percentage % 10 == 0 else { return }
            _self.delegate?.updateStats()
        }

        guard remainingEntries == 0 else { return }

        DispatchQueue.main.async {
            _self.delegate?.initialDataTransferDidComplete()
            _self.parent?.toast.update(
                mode: .foreverSpinner,
                text: "Clearing log",
                disablesBluetoothActions: true,
                onDismiss: nil
            )
        }

        _self.parent?.logCleanup { error in
            DispatchQueue.main.async {
                _self.parent?.toast.dismiss(delay: 0)
                if error != nil {
                    _self.parent?.connectDevice(true)
                }
            }
        }
    }
}
