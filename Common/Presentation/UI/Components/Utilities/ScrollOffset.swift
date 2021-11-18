//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

// MARK: - Preferred Approach
// 1. Set coordinate space
// 2. Set contentHeight Environment value
// 3. Measure minY and maxY relative to 0 and contentHeight

// MARK: - Preference Key Approach

struct ScrollOffsetPreference: View {

    var coordinateSpace: CoordinateSpace

    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: geometry.frame(in: coordinateSpace).origin
            )
        }.frame(width: 0, height: 0)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

// MARK: - Diffing Container Approach

protocol ScrollOffsetDelegate: AnyObject {
    func updateScrollViewportOrigin(asPercentageOfContentWidth update: CGFloat)
}

struct HorizontalScrollOffset: View {

    var delegate: ScrollOffsetDelegate
    var coordinateSpace: CoordinateSpace

    @State private var scrollOriginOffset = CGFloat(0)

    var body: some View {
        GeometryReader { geometry in
            Color.clear.hidden()
                .frame(width: 1, height: 10, alignment: .leading)
                .onAppear {
                    // Find whatever SwiftUI has done for positioning this reporter within the content width
                    let leftMostPixelLocation = geometry.frame(in: .localGraphScrollView).origin.x
                    scrollOriginOffset = geometry.size.width - leftMostPixelLocation
                    delegate.updateScrollViewportOrigin(asPercentageOfContentWidth: 0)
                }
                .onChange(of: geometry.frame(in: coordinateSpace).origin.x) { offsetPixelPosition in
                    // Report the adjusted pixel offset as a percentage of progression through the scroll view
                    let ratio = (offsetPixelPosition + scrollOriginOffset) / geometry.size.width
                    delegate.updateScrollViewportOrigin(asPercentageOfContentWidth: 1 - ratio)
                }
        }
    }
}


// MARK: - Coordinate Spaces

extension CoordinateSpace {

    enum Names: String {
        case DetailScrollView
        case LocalGraphScrollView
    }
    static let iOSDetailScrollView = CoordinateSpace.named(Names.DetailScrollView.rawValue)
    static let localGraphScrollView = CoordinateSpace.named(Names.LocalGraphScrollView.rawValue)
}
