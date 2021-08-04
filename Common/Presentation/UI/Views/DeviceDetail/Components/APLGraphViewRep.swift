//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct APLGraphViewWrapper: View {

    var vm: GraphDelegate

    var body: some View {
        APLGraphViewRep(vm: vm)
            .frame(height: .detailsGraphHeight)
    }
}

struct APLGraphViewRep: UIViewRepresentable {

    var vm: GraphDelegate

    func makeUIView(context: Context) -> APLGraphView {
        let view = APLGraphView()
        vm.graph = view
        return view
    }

    func updateUIView(_ uiView: APLGraphView, context: Context) {
        vm.graph = uiView
    }

}

public protocol GraphDelegate: AnyObject {
    var graph: APLGraphView? { get set }

    func refreshGraphScale()
    func addGraphPoint(x: Double, y: Double, z: Double)
    func willStartNewGraphStream()
}
