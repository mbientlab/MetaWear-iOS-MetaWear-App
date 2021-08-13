//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct MagnetometerBlock: View {

    @ObservedObject var vm: MagnetometerSUIVC

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            LoggingSectionStandardized(vm: vm)
            DividerPadded()
            LiveInspectorSection()
            
            Text("UI is Mockup -> Finishing Today")
                .foregroundColor(.secondary)
        }
        .environmentObject(vm)
    }
}


// MARK: - Live Stream

extension MagnetometerBlock {

    struct LiveInspectorSection: View {

        let graphID = "MagnetometerGraph"

        @EnvironmentObject private var vm: MagnetometerSUIVC
        @Environment(\.scrollProxy) var scroller

        var body: some View {

            LabeledItem(
                label: "Live",
                content: buttons
            )

            if !vm.data.stream.isEmpty {

                StatsBlock(stats: vm.data.getStreamedStats(), count: vm.data.streamCount)

#if os(iOS)
                AAGraphViewWrapper(initialConfig: vm.makeStreamDataConfig(),
                                   graph: vm.setStreamGraphReference)
                    .id(graphID)
                    .onAppear { scrollToGraph() }

#elseif os(macOS)
                if #available(macOS 12.0, *) {
                    CanvasGraph(controller: .init(stream: vm,
                                                  config: vm.makeStreamDataConfig(),
                                                  driver: ThrottledGraphDriver()),
                                width: .detailBlockInnerContentSize)
                        .id(graphID)
                        .onAppear { scrollToGraph() }

                } else {
                    NaiveGraphFixedSize(controller: .init(stream: vm,
                                                          config: vm.makeStreamDataConfig(),
                                                          driver: ThrottledGraphDriver()),
                                        width: .detailBlockInnerContentSize)
                        .id(graphID)
                        .onAppear { scrollToGraph() }
                }
#endif
            }
        }

        private func scrollToGraph() {
            withAnimation {
                scroller?.scrollTo(graphID, anchor: .top)
            }
        }

        private var buttons: some View {

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
                .overlay(connectionProgress, alignment: .leading)
            }

        }

        @ViewBuilder private var connectionProgress: some View {
            if vm.showStreamingStartupSpinner {
                ProgressView()
                    .progressViewStyle(.circular)
#if os(iOS)
                    .transition(.scale)
#elseif os(macOS)
                    .transition(.opacity)
                    .controlSize(.small)
#endif
                    .offset(x: -35)
            }
        }

    }

}
