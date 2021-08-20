//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct PlatformSpecificTwoColumnCardLayout<OptionViews: View, LogView: View, StreamView: View>: View {

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
        VStack(spacing: .cardVSpacing) {
            optionViews
            DividerPadded()
            leftColumn
            DividerPadded()
            rightColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {

                OptionsSymbol()

                HStack(alignment: .firstTextBaseline, spacing: .detailBlockColumnSpacing) {
                    optionViews
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, .detailBlockColumnSpacing)
            }

            DividerPadded()

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: .cardVSpacing) {
                    leftColumn
                }

                VerticalDivider()
                    .frame(maxHeight: .infinity)

                VStack(spacing: .cardVSpacing) {
                    rightColumn
                }
            }
        }
    }
}

struct PlatformSpecificOneColumnCardLayout<OptionViews: View, MainColumn: View>: View {

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
        VStack(spacing: .cardVSpacing) {
            optionViews
            DividerPadded()
            mainColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {
            HStack(alignment: .center, spacing: 0) {

                OptionsSymbol()

                HStack(alignment: .center, spacing: .detailBlockColumnSpacing) {
                    optionViews
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, .detailBlockColumnSpacing)
            }

            DividerPadded()

            mainColumn
        }
    }
}

struct OptionsLabel: View {

    var body: some View {
        Text("Options")
            .fontSmall(weight: .medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OptionsSymbol: View {

    var body: some View {
        Image(systemName: SFSymbol.settings.rawValue)
            .fontSmall(weight: .medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct PlatformSpecificExtraRowCardLayout<OptionViews: View, OtherViews: View, LeftColumn: View, RightColumn: View>: View {

    let optionViews: OptionViews
    let otherViews: OtherViews
    let leftColumn: LeftColumn
    let rightColumn: RightColumn

    var body: some View {
#if os(macOS)
        macOS
#else
        iOS
#endif
    }

    var iOS: some View {
        VStack(spacing: .cardVSpacing) {
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
            HStack(alignment: .firstTextBaseline, spacing: 0) {

                OptionsSymbol()

                HStack(alignment: .firstTextBaseline, spacing: .detailBlockColumnSpacing) {
                    optionViews
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, .detailBlockColumnSpacing)
            }

            DividerPadded()

            HStack(alignment: .top, spacing: 0) {
                otherViews
            }
            DividerPadded()

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: .cardVSpacing) {
                    leftColumn
                }

                VerticalDivider()

                VStack(spacing: .cardVSpacing) {
                    rightColumn
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}


struct PlatformSpecificTwoColumnNoOptionsLayout<LeftColumn: View, RightColumn: View>: View {

    let leftColumn: LeftColumn
    let rightColumn: RightColumn

    var body: some View {
#if os(macOS)
        macOS
#else
        iOS
#endif
    }

    var iOS: some View {
        VStack(spacing: .cardVSpacing) {
            leftColumn
            DividerPadded()
            rightColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: .cardVSpacing) {
                    leftColumn
                }
                VerticalDivider()
                VStack(spacing: .cardVSpacing) {
                    rightColumn
                }
            }
        }
    }
}


struct PlatformSpecificThreeColumnNoOptionsLayout<LeftColumn: View, RightColumn: View, MiddleColumn: View>: View {

    let leftColumn: LeftColumn
    let middleColumn: MiddleColumn
    let rightColumn: RightColumn

    var body: some View {
#if os(macOS)
        macOS
#else
        iOS
#endif
    }

    var iOS: some View {
        VStack(spacing: .cardVSpacing) {
            leftColumn
            DividerPadded()
            middleColumn
            DividerPadded()
            rightColumn
        }
    }

    var macOS: some View {
        VStack(alignment: .leading, spacing: .cardVSpacing) {

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: .cardVSpacing) {
                    leftColumn
                }
                VerticalDivider()
                VStack(spacing: .cardVSpacing) {
                    middleColumn
                }
                VerticalDivider()
                VStack(spacing: .cardVSpacing) {
                    rightColumn
                }
            }
        }
    }
}
