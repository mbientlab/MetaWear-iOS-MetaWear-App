//  © 2021 Ryan Ferrell. github.com/importRyan

import SwiftUI

protocol LoggingSectionDriver: ObservableObject {
    
    var data: MWSensorDataStore { get }
    
    var loggerStats: StatsVM { get }
    var isLogging: Bool { get }
    var isStreaming: Bool { get }
    var allowsNewLogging: Bool { get }
    var logDataIsReadyForDisplay: Bool { get }
    var isDownloadingLog: Bool { get }

    func makeLoggedDataConfig() -> GraphConfig
    
    func setLoggerGraphReference(_ ref: GraphObject)
    func userRequestedLogExport()
    func userRequestedDownloadLog()
    func userRequestedStartLogging()
    func userRequestedStopLogging()
    
}

struct LoggingSectionStandardized<VC: LoggingSectionDriver & LoggerGraphManager>: View {
    
    @EnvironmentObject private var prefs: PreferencesStore
    @ObservedObject var vm: VC
    
    var body: some View {
        LabeledItem(
            label: "Log",
            content: buttons
        )
        
        if vm.logDataIsReadyForDisplay {
            
            StatsBlock(colors: prefs.colorset.value.colors,
                       vm: vm.loggerStats)

            if !vm.isDownloadingLog {
                ScrollingStaticGraph(controller: .init(logger: vm,
                                                       config: vm.makeLoggedDataConfig(),
                                                       driver: ThrottledGraphDriver(interval: 1.5),
                                                       colorProvider: prefs),
                                     width: .detailBlockGraphWidth)
            }
        }
    }
    
    private var buttons: some View {
        
        HStack(alignment: .firstTextBaseline) {
            let disableLogging = vm.isStreaming || (!vm.isLogging && !vm.allowsNewLogging)
            
            ExportDataButton(label: "",
                             isEnabled: vm.logDataIsReadyForDisplay,
                             isPreparing: vm.data.isPreparingLogFile,
                             action: vm.userRequestedLogExport)
            
            Spacer()
            
            DownloadButton(isEnabled: true,
                           onTap: vm.userRequestedDownloadLog)
            
            Spacer()
            
            Button(vm.isLogging ? "Stop" : "Start") {
                if vm.isLogging { vm.userRequestedStopLogging() }
                else { vm.userRequestedStartLogging() }
            }
            .disabled(disableLogging)
            .allowsHitTesting(!disableLogging)
            .opacity(disableLogging ? 0.5 : 1)
        }
    }
}
