//  © 2021 Ryan Ferrell. github.com/importRyan

import SwiftUI

protocol LoggingSectionDriver: ObservableObject {

    var data: MWSensorDataStore { get }

    var loggerStats: MWDataStreamStats { get }
    var isLogging: Bool { get }
    var isStreaming: Bool { get }
    var allowsNewLogging: Bool { get }
    var logDataIsReadyForDisplay: Bool { get }

#if os(iOS)
    func makeLoggedDataConfig() -> GraphConfig
#endif

    func setLoggerGraphReference(_ ref: GraphObject)
    func userRequestedLogExport()
    func userRequestedDownloadLog()
    func userRequestedStartLogging()
    func userRequestedStopLogging()

}

struct LoggingSectionStandardized<VC: LoggingSectionDriver>: View {

    @ObservedObject var vm: VC

    var body: some View {
        LabeledItem(
            label: "Log",
            content: buttons
        )

        if vm.logDataIsReadyForDisplay {

            StatsBlock(stats: vm.loggerStats, count: vm.data.loggedCount)

#if os(iOS)
            AAGraphViewWrapper(initialConfig: vm.makeLoggedDataConfig(),
                               graph: vm.setLoggerGraphReference)
#endif
        }
    }

    private var buttons: some View {

        HStack(alignment: .firstTextBaseline) {
            let disableLogging = vm.isStreaming || (!vm.isLogging && !vm.allowsNewLogging)

            ExportDataButton(label: "",
                             isEnabled: vm.logDataIsReadyForDisplay,
                             action: vm.userRequestedLogExport)

            Spacer()

            DownloadButton(isEnabled: true,
                           onTap: vm.userRequestedDownloadLog)

            Spacer()

            Button(vm.isLogging ? "Stop" : "Log") {
                if vm.isLogging { vm.userRequestedStopLogging() }
                else { vm.userRequestedStartLogging() }
            }
            .disabled(disableLogging)
            .allowsHitTesting(!disableLogging)
            .opacity(disableLogging ? 0.5 : 1)
        }
    }
}
