//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DividerPadded: View {

    init(_ vertical: CGFloat = 5) {
        self.padding = vertical
    }

    var padding: CGFloat

    var body: some View {
        Divider().padding(.vertical, padding)
    }
}
