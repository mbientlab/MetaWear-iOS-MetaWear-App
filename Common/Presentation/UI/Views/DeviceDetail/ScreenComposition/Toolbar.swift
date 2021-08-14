//  Created by Ryan Ferrell on 8/13/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct Toolbar: ToolbarContent {

    @ObservedObject var store: MWSignalsStore
    @ObservedObject var vm: DetailHeaderSUIVC

    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
            ConnectionToolbarButton(vm: vm)
                .accentColor(.accentColor)
                .foregroundColor(.accentColor)
        }
        #elseif os(macOS)
        ToolbarItemGroup(placement: .status) {
            LoggerToolbarItem(vm: vm, store: store)
            Spacer(minLength: 90)
            ConnectionToolbarButton(vm: vm)
        }
        #endif
    }
}

struct LoggerToolbarItem: View {

    @ObservedObject var vm: DetailHeaderSUIVC
    @ObservedObject var store: MWSignalsStore

    @State private var popover = false
    var body: some View {
        Button(label) { popover.toggle(); store.getLogSize() }
            .popover(isPresented: $popover) {
                LoggerInspector(store: store)
                    .frame(width: 300)
            }
            .opacity(vm.didShowConnectionLED ? 1 : 0)
            .animation(.easeIn, value: vm.didShowConnectionLED)
            .animation(.easeIn, value: store.logSize)
    }

    var label: String {
        store.logSize.isEmpty ? "Logs" : "Logs   \(store.logSize)"
    }

}

struct LoggerInspector: View {

    @ObservedObject var store: MWSignalsStore

    var body: some View {
        VStack(alignment: .leading) {

            if store.loggers.isEmpty {
                Text("No known active loggers")
                    .fontBody(weight: .regular)

            } else {
                loggersList
            }

            #if os(macOS)
            controls
                .buttonStyle(BorderedButtonStyle())
            #elseif os(iOS)
            controls
                .buttonStyle(BorderlessButtonStyle())
            #endif
        }
        .padding(.cardGridSpacing)
    }

    var controls: some View {
        HStack {

            Button("Erase Data") { store.clearLog() }

            Spacer()

            Button("Stop All") { store.stopLogging() }

            if !store.loggers.isEmpty {
                Spacer()
                Button("Start All") { store.startLogging() }
            }
        }
        .padding(.top, .cardGridSpacing)
    }

    @ViewBuilder var loggersList: some View {
        Text("Active Logger Identifiers")
            .fontBody(weight: .medium)

        ForEach(store.loggers.keys.map {$0}, id: \.self) {
            Text($0)
        }.padding()
    }
}
