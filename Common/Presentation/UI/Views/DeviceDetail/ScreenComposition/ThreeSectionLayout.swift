//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct OneSectionLayout<OptionViews: View, MainColumn: View>: View {

    let optionViews: OptionViews
    let mainColumn: MainColumn

    var body: some View {
#if os(macOS)
        macOS
#else
        iOS
#endif
    }

    var iOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            optionViews
            DividerPadded()
            mainColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            OptionLayout(optionViews: optionViews).zIndex(-3)
            mainColumn
        }
    }
}

struct TwoSectionLayout<OptionViews: View, LogView: View, StreamView: View>: View {

    let optionViews: OptionViews
    let leftColumn: LogView
    let rightColumn: StreamView

    var body: some View {
#if os(macOS)
        macOS
#else
        iOS
#endif
    }

    var iOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            optionViews
            DividerPadded()
            leftColumn
            DividerPadded()
            rightColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            OptionLayout(optionViews: optionViews).zIndex(-3)
            leftColumn
            DividerPadded()
            rightColumn
        }
    }
}

struct ThreeSectionLayout<OptionViews: View, OtherViews: View, LeftColumn: View, RightColumn: View>: View {

    let optionViews: OptionViews
    let otherViews: OtherViews
    let leftColumn: LeftColumn
    let rightColumn: RightColumn

    var body: some View {
#if os(iOS) && !targetEnvironment(macCatalyst)
        iOS
#else
        macOS
#endif
    }

    var iOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            optionViews
            DividerPadded()
            otherViews
            DividerPadded()
            leftColumn
            DividerPadded()
            rightColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            OptionLayout(optionViews: optionViews).zIndex(-3)
            otherViews
            DividerPadded()
            leftColumn
            DividerPadded()
            rightColumn
        }
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}


struct TwoSectionNoOptionsLayout<LeftColumn: View, RightColumn: View>: View {

    let leftColumn: LeftColumn
    let rightColumn: RightColumn

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            leftColumn
            DividerPadded()
            rightColumn
        }
    }
}

struct TripleColumnNoOptionsLayout<LeftColumn: View, RightColumn: View, MiddleColumn: View>: View {

    let leftColumn: LeftColumn
    let middleColumn: MiddleColumn
    let rightColumn: RightColumn

    var body: some View {
        VStack(spacing: .cardVSpacing) {
            leftColumn
            DividerPadded()
            middleColumn
            DividerPadded()
            rightColumn
        }
    }
}

struct OptionLayout<Content: View>: View {

    var optionViews: Content

    var body: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            optionViews
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.detailBlockCorners * 2)
        .padding(.bottom, -.detailBlockCorners)
        .background(color: .optionsBackground, in: RoundedRectangle(cornerRadius: .detailBlockCorners))
        .padding(.horizontal, -.detailBlockOuterPadding * 1.5)
        .padding(.bottom, -.cardVSpacing)
        .offset(y: -.cardVSpacing - (.detailBlockCorners * 1.5))
    }
}

struct OptionsSymbol: View {

    var body: some View {
        Image(systemName: SFSymbol.settings.rawValue)
            .fontSmall(weight: .medium)
            .foregroundColor(.mwSecondary)
    }
}
