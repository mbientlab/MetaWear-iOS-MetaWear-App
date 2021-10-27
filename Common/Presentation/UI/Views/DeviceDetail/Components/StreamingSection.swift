//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

protocol StreamingSectionDriver: StreamGraphManager, ObservableObject {

    var data: MWSensorDataStore { get }

    var streamingStats: StatsVM { get }
    var isLogging: Bool { get }
    var isStreaming: Bool { get }
    var allowsNewStreaming: Bool { get }
    var showStreamingStartupSpinner: Bool { get }

    func makeStreamDataConfig() -> GraphConfig
    func setStreamGraphReference(_ ref: GraphObject)
    func userRequestedStreamExport()
    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
}

struct LiveStreamSection<VM: StreamingSectionDriver>: View {

    /// "GyroscropeStreamGraph"
    var scrollViewGraphID: String

    @ObservedObject var vm: VM
    @EnvironmentObject var prefs: PreferencesStore

    var body: some View {
        LabeledItem(
            label: "Stream",
            content: StartStopExportControls(vm: vm)
        )

        if vm.isStreaming || vm.data.streamCount > 0 {

            StatsBlock.LayoutPerformanceWorkaround(colors: prefs.colorset.value.colors, vm: vm.streamingStats)
            Graph(vm: vm, scrollViewGraphID: scrollViewGraphID)
        }
    }
}

// MARK: - Controls

fileprivate struct StartStopExportControls<VM: StreamingSectionDriver>: View {

    @ObservedObject var vm: VM

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            let disableStreaming = vm.isLogging || (!vm.isStreaming && !vm.allowsNewStreaming)

            ExportDataButton(label: "",
                             isEnabled: !vm.isStreaming && !vm.data.stream.isEmpty,
                             isPreparing: vm.data.isPreparingStreamFile,
                             action: vm.userRequestedStreamExport)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Start") {
                if vm.isStreaming { vm.userRequestedStopStreaming() }
                else { vm.userRequestedStartStreaming() }
            }
            .disabled(disableStreaming)
            .allowsHitTesting(!disableStreaming)
            .opacity(disableStreaming ? 0.5 : 1)
            .overlay(IsConnectingToStreamIndicator(vm: vm), alignment: .leading)
        }
    }
}

// MARK: - Connecting Spinner

fileprivate struct IsConnectingToStreamIndicator<VM: StreamingSectionDriver>: View {

    @ObservedObject var vm: VM

    var body: some View {
        if vm.showStreamingStartupSpinner {
            SmallCircularProgressView()
                .offset(x: -35)
        }
    }

}

// MARK: - Graph

fileprivate struct Graph<VM: StreamingSectionDriver>: View {

    @EnvironmentObject private var prefs: PreferencesStore
    @ObservedObject var vm: VM
    var scrollViewGraphID: String
    @Environment(\.scrollProxy) private var scroller

    private func scrollToGraph() {
        withAnimation { scroller?.scrollTo(scrollViewGraphID, anchor: .top) }
    }

    var body: some View {
        ZStack {
            if vm.isStreaming {

                FeedPlotFixedSize(controller: .init(stream: vm,
                                                           config: vm.makeStreamDataConfig(),
                                                           colorProvider: prefs),
                                         width: .detailBlockGraphWidth)
                           .padding(.top, .standardVStackSpacing)
                           .id(scrollViewGraphID)

            } else if !vm.data.stream.isEmpty {

                ScrollingStaticGraph(controller: .init(stream: vm,
                                                       config: vm.makeStreamDataConfig(),
                                                       driver: ThrottledGraphDriver(interval: 1.5),
                                                       colorProvider: prefs),
                                     width: .detailBlockGraphWidth)
                    .padding(.top, .standardVStackSpacing)
            } else {
                Text("Error")
            }
        }
    }
}
