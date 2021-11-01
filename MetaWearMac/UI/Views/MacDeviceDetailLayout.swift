//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

struct MacDeviceDetailLayout: View {
    var chain: Namespace.ID
    var details: Namespace.ID

    @State private var focus: DetailGroup? = nil

    var body: some View {
        HSplitView {
            MacOSDeviceDetailList(chain: chain, details: details, focus: $focus)
                .frame(width: .macOSHSplitListWidth + (.detailBlockOuterPadding * 2))

            MacOSFocusedModuleView(focus: $focus, details: details)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - List

struct MacOSDeviceDetailList: View {

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    var chain: Namespace.ID
    var details: Namespace.ID
    @Binding var focus: DetailGroup?

    var body: some View {
        VStack {
            Header(vm: vc.vms.identifiers as! IdentifiersSUIVC)
                .padding(.leading, .detailBlockContentPadding * 3)

            List(selection: $focus) {

                if vc.sortedVisibleGroups.contains(.signal) {

                    Cell(group: .identifiers, isSelected: focus == .identifiers)
                        .onAppear { focus = .identifiers }

                    LogCell(store: vc.signals as! MWSignalsStore, isSelected: focus == .logs)

                    if #available(macOS 12.0, *) {
                        Section("Modules") {
                            ForEach(vc.sortedVisibleGroups.filter { !Self.infoGroups.contains($0) }) { group in
                                Cell(group: group, isSelected: focus == group)
                            }
                        }
                    } else {
                        Section(header: Text("Modules")) {
                            ForEach(vc.sortedVisibleGroups.filter { !Self.infoGroups.contains($0) }) { group in
                                Cell(group: group, isSelected: focus == group)
                            }
                        }
                    }
                }
            }
            .listRowInsets(.init(top: 6, leading: .detailBlockContentPadding * 2, bottom: 6, trailing: .detailBlockContentPadding))
            .listStyle(InsetListStyle())
            .edgesIgnoringSafeArea(.all)
        }
        .animation(.easeOut, value: vc.sortedVisibleGroups)
        .background(Color(.textBackgroundColor))
    }

    private static let infoGroups: Set<DetailGroup> = Set([.identifiers, .signal, .reset, .ibeacon, .headerInfoAndState, .logs])

    fileprivate struct LogCell: View {
        @ObservedObject var store: MWSignalsStore
        var isSelected: Bool
        var body: some View {
            Cell(group: .logs, accessory: store.logSize, isSelected: isSelected)
                .onAppear { store.getLogSize() }
        }
    }

    fileprivate struct Cell: View {
        @Environment(\.colorScheme) private var colorScheme
        var group: DetailGroup
        var accessory: String = ""
        var isSelected: Bool

        var body: some View {
            HStack {
                group.symbol.image()
                    .frame(width: MWBody.fontSize * 2, alignment: .leading)

                Text(group.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 6)

                Spacer()

                Text(accessory)
                    .foregroundColor(isSelected ? nil : .mwSecondary)
                    .padding(.horizontal, .detailBlockContentPadding)
                    .animation(.easeOut(duration: 0.1), value: isSelected)
            }
            .fontBody(weight: colorScheme == .dark ? .medium : .regular)
            .tag(group)
        }
    }
}

// MARK: - Focused Module

struct MacOSFocusedModuleView: View {

    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Binding var focus: DetailGroup?
    var details: Namespace.ID

    var body: some View {
        if focus == .identifiers { device }
        else if focus == nil { Spacer() }
        else { standard }
    }

    var standard: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: .detailBlockContentPadding) {
                BlockBuilder(group: focus ?? .headerInfoAndState, namespace: details)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(focus?.title ?? "No selection")
            }
            .padding(.top, MWLargeTitle.fontSize * 1.5)
            .padding(.horizontal, .detailBlockContentPadding)
            .padding(.leading, .detailBlockContentPadding)
            .padding(.bottom, MWLargeTitle.fontSize * 1.5)
        }
    }

    private static let combinedDeviceGroup: Array<DetailGroup> = [.identifiers, .signal, .reset, .ibeacon]
    // Combined identifiers + signal, reset, iBeacon
    var device: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: .detailBlockContentPadding * 3) {
                ForEach(Self.combinedDeviceGroup) { group in
                    BlockBuilder(group: group, namespace: details)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(focus?.title ?? "No selection")
                }
            }
            .padding(.top, MWLargeTitle.fontSize * 1.5)
            .padding(.horizontal, .detailBlockContentPadding)
            .padding(.leading, .detailBlockContentPadding)
            .padding(.bottom, MWLargeTitle.fontSize * 1.5)
        }
    }
}
