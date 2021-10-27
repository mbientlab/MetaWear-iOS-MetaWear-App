//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

struct MacDeviceDetailLayout: View {
    var chain: Namespace.ID
    var details: Namespace.ID
    @EnvironmentObject private var vc: DeviceDetailScreenSUIVC
    @Environment(\.fontFace) private var fontFace
    
    var body: some View {
        VStack(alignment: .leading, spacing: .cardGridSpacing) {
            HStack {
                Header()
                
                if vc.sortedVisibleGroups.contains(.reset) {
                    block(for: .reset)
                        .padding(.leading, .detailBlockColumnSpacing)
                } else {
                    Spacer(minLength: .detailBlockWidth + .detailBlockColumnSpacing)
                }
            }
            
            VStack(alignment: .leading, spacing: .cardGridSpacing) {
                ForEach(vc.sortedVisibleGroups.filter { !Self.infoGroups.contains($0) } ) { group in
                    block(for: group)
                }
            }
        }
        .frame(width: .detailBlockWidth * 2 + .detailBlockColumnSpacing, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
        .padding(.top, fontFace == .openDyslexic ? 28 : 18)
    }
    
    
    func block(for group: DetailGroup) -> some View {
        BlockBuilder(group: group, namespace: details)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(group.title)
            .matchedGeometryEffect(id: group, in: details, properties: .position, anchor: .leading, isSource: false)
    }
    
    static let infoGroups: Set<DetailGroup> = [.headerInfoAndState, .identifiers, .signal, .reset, .ibeacon]
}
