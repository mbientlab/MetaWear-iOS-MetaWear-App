//  Created by Ryan on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct DownloadButton: View {

    var isEnabled: Bool
    var onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            Image(systemName: SFSymbol.download.rawValue)
        }
        .help("Download")
        .accessibilityLabel(SFSymbol.download.accessibilityDescription)
        .accessibilityAddTraits(.isButton)

        .disabled(!isEnabled)
        .allowsHitTesting(isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}
