//  Created by Ryan Ferrell.
//  Copyright © 2021 MbientLab. All rights reserved.

import SwiftUI

struct LogsBlock: View {

    @ObservedObject var store: MWSignalsStore

    var body: some View {
        TwoSectionNoOptionsLayout(
            leftColumn: info,
            rightColumn: controls
        )
            .onAppear { store.getLogSize() }
            .animation(.easeIn, value: store.logSize)
    }

    @ViewBuilder var info: some View {
        LabeledItem(label: "Bytes", content: logSize)
        LabeledItem(label: "Known", content: loggersList.fontBody(weight: .medium))
    }

    var controls: some View {
        HStack {
            Spacer()
            Button("Stop All") { store.stopLogging() }
            if !store.loggers.isEmpty {
                Spacer()
                Button("Start All") { store.startLogging() }
            }
            Spacer()
        }
    }

    var logSize: some View {
        HStack {
            Text(store.logSize).fontBody(weight: .medium)
            Spacer(minLength: 5)
#if os(macOS)
            delete_macOS
#else
            delete_iOS
#endif
        }
    }

    private var delete_iOS: some View {
        Menu {
            Button("Clear data only") { store.clearEntries() }
            Button("Remove data and loggers") { store.clearEntriesAndRemoveLoggers() }
        } label: { SFSymbol.delete.image() }
        .fixedSize()
        .accessibilityLabel(Text(SFSymbol.delete.accessibilityDescription))
    }

    @ViewBuilder private var delete_macOS: some View {
        Button { store.clearEntries() } label: { SFSymbol.wipe.image() }
        .accessibilityLabel(Text(SFSymbol.wipe.accessibilityDescription))
        .help(Text("Clear data only"))

        Button { store.clearEntriesAndRemoveLoggers() } label: { SFSymbol.delete.image() }
        .accessibilityLabel(Text(SFSymbol.delete.accessibilityDescription))
        .help(Text("Remove data and loggers"))
    }

    var loggersList: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: .standardVStackSpacing) {
                if store.loggers.isEmpty {
                    Text("None")
                } else {
                    ForEach(store.loggers.keys.map {$0}, id: \.self) {
                        Text($0)
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)

            UpdateButton(didTap: {
                store.getLogSize()
            }, helpAccessibilityLabel: "Refresh")
        }
    }
}
