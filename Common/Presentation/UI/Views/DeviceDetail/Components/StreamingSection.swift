//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

protocol StreamingSectionDriver: StreamGraphManager, ObservableObject {

    var data: MWSensorDataStore { get }

    var streamingStats: MWDataStreamStats { get }
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
            label: "Live",
            content: StartStopExportControls(vm: vm)
        )

        if !vm.data.stream.isEmpty {
            StatsBlock(colors: prefs.colorset.value.colors,
                       stats: vm.streamingStats,
                       count: vm.data.streamCount)
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
                             action: vm.userRequestedStreamExport)

            Spacer()

            Button(vm.isStreaming ? "Stop" : "Stream") {
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
            platformSpecificView
        }
    }

    var platformSpecificView: some View {
#if os(macOS)
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .transition(.opacity)
            .controlSize(.small)
            .offset(x: -35)
#elseif os(iOS)
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .transition(.scale)
            .offset(x: -35)
#endif
    }

}

// MARK: - Graph

fileprivate struct Graph<VM: StreamingSectionDriver>: View {

    @EnvironmentObject private var prefs: PreferencesStore
    @ObservedObject var vm: VM
    var scrollViewGraphID: String
    @Environment(\.scrollProxy) private var scroller

    private func scrollToGraph() {
        withAnimation { scroller?.scrollTo(scrollViewGraphID, anchor: .center) }
    }

    var body: some View {
#if os(iOS)
        iOSGraph
#elseif os(macOS)
        macOSGraph.padding(.vertical, .standardVStackSpacing)
#endif
    }

#if os(iOS)
    var iOSGraph: some View {
        AAGraphViewWrapper(initialConfig: vm.makeStreamDataConfig(),
                           graph: vm.setStreamGraphReference)
            .id(scrollViewGraphID)
            .onAppear { scrollToGraph() }
    }
#endif

#if os(macOS)
    @ViewBuilder var macOSGraph: some View {
#if swift(>=5.5)
        if #available(macOS 12.0, *) {
            CanvasGraph(controller: .init(stream: vm,
                                          config: vm.makeStreamDataConfig(),
                                          driver: ThrottledGraphDriver(), colorProvider: prefs),
                        width: .detailBlockInnerContentSize - 70)
                .id(scrollViewGraphID)
                .onAppear { scrollToGraph() }
        } else {
            macOS11Graph
        }
#else
        macOS11Graph
#endif

    }

    var macOS11Graph: some View {
        NaiveGraphFixedSize(controller: .init(stream: vm,
                                              config: vm.makeStreamDataConfig(),
                                              driver: ThrottledGraphDriver(),
                                              colorProvider: prefs),
                            width: .detailBlockInnerContentSize - 70)
            .id(scrollViewGraphID)
            .onAppear { scrollToGraph() }
    }
#endif
}
