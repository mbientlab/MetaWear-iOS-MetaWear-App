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
    func updateScrollOffset(_ update: CGFloat)
}

struct HorizontalScrollOffset: View {

    var delegate: ScrollOffsetDelegate
    var coordinateSpace: CoordinateSpace

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear { delegate.updateScrollOffset(geometry.frame(in: coordinateSpace).origin.x) }
                .onChange(of: geometry.frame(in: coordinateSpace).origin.x) { delegate.updateScrollOffset($0) }
        }.frame(width: 0, height: 0)
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
