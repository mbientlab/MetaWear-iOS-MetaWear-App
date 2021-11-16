//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct UpdateButton: View {

    var didTap: () -> Void
    var helpAccessibilityLabel: String

    var body: some View {
        Button { didTap() } label: {
            Image(systemName: SFSymbol.refresh.rawValue)
                .accessibilityLabel(SFSymbol.refresh.accessibilityDescription)
        }
        .help(helpAccessibilityLabel)
        .accessibilityLabel(helpAccessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
}
