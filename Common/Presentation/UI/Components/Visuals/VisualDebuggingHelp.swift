//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

extension View {

    func debugBorderDisplaySize(color: Color) -> some View {
        #if DEBUG
        border(color)
        .overlay(
        GeometryReader { geo in
            Text(String(format: "%1.1f w", geo.size.width) + String(format: "%1.1f h", geo.size.height))
                .padding(3)
                .background(Color.black)
                .foregroundColor(color)
        })
        #else
        self
        #endif
    }
}
