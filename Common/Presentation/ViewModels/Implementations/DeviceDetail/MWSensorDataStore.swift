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

    public var loggedCount: Int { logged.endIndex }
    public var streamCount: Int { stream.endIndex }

    public private(set) var isPreparingStreamFile = false
    public private(set) var isPreparingLogFile = false
    public private(set) var logURL: URL? = nil
    public private(set) var streamURL: URL? = nil

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
        logURL = nil
        loggedKind = newKind
    }

    func clearStreamed(newKind: DataPointKind) {
        stream = []
        streamURL = nil
        streamKind = newKind
    }

    func exportLogData(filePrefix: String, didStartPreparingFile: @escaping () -> Void, completion: @escaping (Result<URL,Error>) -> Void) {
        if let url = logURL {
            completion(.success(url))
            return
        }

        guard isPreparingLogFile == false else { return }
        isPreparingLogFile = true
        DispatchQueue.main.async {
            didStartPreparingFile()
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let data = self.makeLogData()

            let fileName = self.getFilenameByDate(and: "\(filePrefix)LogData")
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL, options: .atomic)
                DispatchQueue.main.async { [weak self] in
                    self?.isPreparingLogFile = false
                    completion(.success(fileURL))
                }
            } catch let error {
                DispatchQueue.main.async { [weak self] in
                    self?.isPreparingLogFile = false
                    completion(.failure(error))
                }
            }
        }
    }

    func exportStreamData(filePrefix: String, didStartPreparingFile: @escaping () -> Void, completion: @escaping (Result<URL,Error>) -> Void) {
        if let url = streamURL {
            completion(.success(url))
            return
        }

        guard isPreparingStreamFile == false else { return }
        DispatchQueue.main.async {
            self.isPreparingStreamFile = true
            didStartPreparingFile()
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let data = self.makeStreamData()

            let fileName = self.getFilenameByDate(and: "\(filePrefix)StreamData")
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL, options: .atomic)
                DispatchQueue.main.async { [weak self] in
                    self?.isPreparingStreamFile = false
                    completion(.success(fileURL))
                }
            } catch let error {
                DispatchQueue.main.async { [weak self] in
                    self?.isPreparingStreamFile = false
                    completion(.failure(error))
                }
            }
        }
    }

    private func getFilenameByDate(and name: String) -> String {
        let dateString = dateFormatter.string(from: Date())
        return "\(name)_\(dateString).csv"
    }

}

/// MM_dd_yyyy-HH_mm_ss
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
    return formatter
}()

private extension MWSensorDataStore {

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


// MARK: - EXPORT

import SwiftUI

public class FileExporter: ObservableObject {

    @Published var showExportDialog = false
    var document: CSVDocument? = nil
    var defaultFilename: String? = nil
    var exportableFileURL: URL? = nil

    private var alerts: AlertPresenter? = nil

    func export(fileURL: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.presentFileExportDialog(fileURL: fileURL)
        }
    }

#if os(iOS)
    public func presentFileExportDialog(fileURL: URL) {
        self.document = try? CSVDocument(csvURL: fileURL)
        self.defaultFilename = fileURL.deletingPathExtension().lastPathComponent.appending(".csv")
        guard document != nil else { return }
        showExportDialog = true
    }

#elseif os(macOS)

    lazy var panel = configureSavePanel(prompt: "Save MetaWear Data", name: "")

    public func presentFileExportDialog(fileURL: URL) {

        guard let window = NSApp.keyWindow else { return }
        panel.nameFieldStringValue = fileURL.lastPathComponent

        panel.beginSheetModal(for: window) { [weak self] (response) in
            guard response == .OK,
                  let url = self?.panel.url else { return }

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                do {
                    try FileManager.default.copyItem(at: fileURL, to: url)
                } catch let error {
                    NSLog(error.localizedDescription)
                    DispatchQueue.main.async { [weak self] in
                        self?.panel.orderOut(nil)
                        self?.alerts?.presentAlert(title: "Save Error", message: error.localizedDescription)
                    }
                }
            }
        }

    }

    private func configureSavePanel(prompt: String, name: String) -> NSSavePanel {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.showsHiddenFiles = true
        panel.canSelectHiddenExtension = true
        panel.prompt = prompt
        panel.nameFieldStringValue = name
        return panel
    }

#endif

}

// MARK: - SwiftUI-style File Export

#if canImport(SwiftUI)
import SwiftUI
import UniformTypeIdentifiers

public struct CSVDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.spreadsheet] }
    var data: Data

    public init(csvURL: URL) throws {
        guard FileManager.default.fileExists(atPath: csvURL.path) else { throw CocoaError(.fileNoSuchFile) }
        self.data = try Data(contentsOf: csvURL)
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else { throw CocoaError(.fileReadCorruptFile) }
        self.data = data
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: self.data)
    }
}
#endif
