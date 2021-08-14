//  Created by Ryan Ferrell on 8/12/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct SmallTextField: View {

    @Environment(\.fontFace) private var fontFace

    var smallest: Bool = false
    var initialText: String
    var placeholder: String
    /// Triggers animation on any change.
    var invalidEntry: Bool
    var onCommit: (String) -> Void

    @State private var text = ""
    @State private var showValidationNotice = false
    @ScaledMetric(relativeTo: .body) var size = MWBody.fontSize

    var body: some View {
        HStack {
            #if os(macOS)
            macTextField
            #else
            textField
            #endif
        }
        .onAppear { text = initialText }
        .onChange(of: initialText) { text = $0 }
        .modifier(ShakeEffect(shakes: invalidEntry ? 2 : 0))
        .animation(Animation.easeIn.speed(2), value: invalidEntry)
        .padding(.top, 2)
    }
#if os(macOS)
    private var macTextField: some View {
        SingleLineTextField(initialText: text,
                            placeholderText: placeholder,
                            config: .bodyStyle(face: fontFace, alignment: .right),
                            onCommit: validateTextFieldCommit,
                            onCancel: { }
        )
            .frame(width: .detailBlockWidth * (smallest ? 0.2 : 0.4),
                   height: fontFace == .openDyslexic ? size + 8 : size + 5,
                   alignment: .trailing)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.controlBackgroundColor))
                    .offset(y: -1)
            )
    }

    func validateTextFieldCommit(_ string: String) {
        text = string
        onCommit(text)
    }
#endif

    private var textField: some View {
        TextField(placeholder, text: $text) { _ in } onCommit: {
            onCommit(text)
        }
        .fontBody()
        .multilineTextAlignment(.trailing)
    }
}
