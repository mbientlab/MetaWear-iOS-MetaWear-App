//  © 2021 Ryan Ferrell. github.com/importRyan


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
            Button { store.clearLog() } label: { SFSymbol.delete.image() }
            .accessibilityLabel(Text(SFSymbol.delete.accessibilityDescription))
        }
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
