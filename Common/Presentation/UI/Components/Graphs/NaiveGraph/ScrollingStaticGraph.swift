//  Created by Ryan Ferrell on 8/8/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

/// Naive implementation using Canvas (accelerated) in Monterey/iOS 15 and CoreGraphics in prior releases
struct ScrollingStaticGraph: View {

    @StateObject var controller: ScrollingStaticGraphController

    let width: CGFloat
    let height: CGFloat = .detailsGraphHeight
    static let dotSize = CGFloat(2.5)

    var body: some View {
        VStack(spacing: 16) {

            ScrolledGraph(controller: controller, height: height, scrollOffset: $controller.focus.scrollOffset)
                .frame(width: width, height: height)

            /// For mouse hover
                .overlay(
                    FocusedPointOverlay(width: width, height: height, controller: controller)
                        .whenHoveredAtPoint { controller.mouseMoved(to: $0, width: width, dotSize: Self.dotSize) }
                )

            FocusedPointDataLabels(width: width, controller: controller)
        }
        .padding(.vertical, 8)
    }

}

// MARK: - Graph

extension ScrollingStaticGraph {

    /// Graph points
    struct ScrolledGraph: View {

        @ObservedObject var controller: ScrollingStaticGraphController
        let height: CGFloat
        @Binding var scrollOffset: CGFloat

        var body: some View {
            ScrollView(.horizontal, showsIndicators: true) {
                ScrollOffsetMeasurer()
                Graph(controller: controller, height: height)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in scrollOffset = offset.x }
            .background(PlotBackgroundLinesAndLabels(min: controller.yMin, max: controller.yMax))
            .background(Color.plotBackground)
        }
    }

    struct Graph: View {

        @ObservedObject var controller: ScrollingStaticGraphController
        let height: CGFloat
        let pointSize = CGSize(width: ScrollingStaticGraph.dotSize, height: ScrollingStaticGraph.dotSize)

        var body: some View {
            if #available(macOS 12.0, iOS 15.0, *) {
                canvasGPU
            } else {
                legacyCPU
            }
        }

        @available(macOS 12.0, iOS 15.0, *)
        var canvasGPU: some View {
            Canvas(opaque: true, colorMode: .nonLinear, rendersAsynchronously: true) { context, size in

                controller.displayedPoints.forEach { timepoint in
                    timepoint.heights.indices.forEach { seriesIndex in

                        let x = timepoint.x * ScrollingStaticGraph.dotSize
                        let y = (timepoint.heights[seriesIndex] / controller.rangeY * height) + (height / 2) - 1.5

                        let path = makePoint(x: x, y: y)
                        context.fill(path, with: .color(controller.seriesColors[seriesIndex]))
                    }
                }

            }
            .frame(width: CGFloat(controller.displayedPoints.endIndex) * ScrollingStaticGraph.dotSize,
                   height: height)
        }

        func makePoint(x: CGFloat, y: CGFloat) -> Path {
            Path(ellipseIn: .init(origin: CGPoint(x: x, y: y),
                                  size: pointSize))
        }

        var legacyCPU: some View {
            ZStack {
                ForEach(controller.seriesNames.indices) { index in
                    SeriesPlot(controller: controller, index: index)
                        .foregroundColor(controller.seriesColors[index])
                }
            }
            .frame(width: CGFloat(controller.displayedPoints.endIndex) * ScrollingStaticGraph.dotSize,
                   height: height)
            .drawingGroup(opaque: true, colorMode: .nonLinear)
        }

        struct SeriesPlot: Shape {
            @ObservedObject var controller: ScrollingStaticGraphController
            let index: Int

            func path(in rect: CGRect) -> Path {
                var path = Path()
                let size = CGSize(width: ScrollingStaticGraph.dotSize, height: ScrollingStaticGraph.dotSize)

                for timepoint in controller.displayedPoints {
                    let relativeValue = timepoint.heights[index] / controller.rangeY
                    let y = relativeValue * rect.height + (rect.height / 2)
                    print(index, y)
                    let origin = CGPoint(x: timepoint.x * ScrollingStaticGraph.dotSize, y: y)
                    path.move(to: origin)
                    path.addEllipse(in: CGRect(origin: origin, size: size))
                }

                return path
            }

        }
    }

}

// MARK: - Scrolling

extension ScrollingStaticGraph {

    struct ScrollOffsetMeasurer: View {

        var body: some View {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).origin
                )
            }.frame(width: 0, height: 0)
        }
    }

}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}


// MARK: - Components

extension ScrollingStaticGraph {

    struct Dot: View {

        let color: Color
        let size: CGFloat

        var body: some View {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
    }

    struct FocusedPointDataLabels: View {

        let width: CGFloat
        init(width: CGFloat, controller: ScrollingStaticGraphController) {
            self.controller = controller
            self.focus = controller.focus
            self.width = width
        }

        @ObservedObject var controller: ScrollingStaticGraphController
        @ObservedObject var focus: FocusedIndexVM

        @Environment(\.sizeCategory) private var typeSize

        var body: some View {
            VStack(alignment: .leading) {
                if typeSize.isAccessibilityCategory {
                    allLabels
                } else if controller.seriesNames.countedByEndIndex() > 3 {

                    HStack { oddLabels }
                    HStack { evenLabels }

                } else {
                    HStack { allLabels }
                }
            }
            .frame(width: width, alignment: .leading)
            .opacity(focus.showDataLabel ? 1 : 0)
            .animation(.easeInOut(duration: 0.16), value: focus.showDataLabel)
        }

        private var placeholder: some View {
            PointLabel(width: width / 2, color: .clear, value: 0).hidden()
        }

        @ViewBuilder private var allLabels: some View {
            if let index = focus.index, controller.displayedPoints.indices.contains(index) {
                ForEach(controller.displayedPoints[index].heights.indices, id: \.self) { seriesIndex in

                    PointLabel(width: width / CGFloat(controller.seriesColors.countedByEndIndex()),
                               color: controller.seriesColors[seriesIndex],
                               value: controller.displayedPoints[index].heights[seriesIndex]
                    )
                }
            } else { placeholder }
        }

        @ViewBuilder private var evenLabels: some View {
            if let index = focus.index, controller.displayedPoints.indices.contains(index) {
                ForEach(controller.displayedPoints[index].heights.indices, id: \.self) { seriesIndex in

                    if seriesIndex % 2 == 0 {
                        PointLabel(width: width / CGFloat(controller.seriesColors.countedByEndIndex() / 2),
                                   color: controller.seriesColors[seriesIndex],
                                   value: controller.displayedPoints[index].heights[seriesIndex]
                        )
                    }
                }
            } else { placeholder }
        }

        @ViewBuilder private var oddLabels: some View {
            if let index = focus.index, controller.displayedPoints.indices.contains(index) {
                ForEach(controller.displayedPoints[index].heights.indices, id: \.self) { seriesIndex in

                    if seriesIndex % 2 != 0 {
                        PointLabel(width: width / CGFloat(controller.seriesColors.countedByEndIndex() / 2),
                                   color: controller.seriesColors[seriesIndex],
                                   value: controller.displayedPoints[index].heights[seriesIndex]
                        )
                    }
                }
            } else { placeholder }
        }

        struct PointLabel: View {

            let width: CGFloat
            let color: Color
            let value: CGFloat
            @Environment(\.sizeCategory) private var typeSize

            var body: some View {
                HStack {
                    let size: CGFloat = typeSize.isAccessibilityCategory ? 25 : 11
                    Circle().fill(color).frame(width: size, height: size)
                    Text(String(format: "%1.2f", value))
                        .fontSmall(monospacedDigit: true)
                }
                .frame(width: width, alignment: .leading)
            }
        }
    }

    struct FocusedPointOverlay: View {

        let width: CGFloat
        let height: CGFloat
        init(width: CGFloat, height: CGFloat, controller: ScrollingStaticGraphController) {
            self.width = width
            self.height = height
            self.focus = controller.focus
        }
        @ObservedObject var focus: FocusedIndexVM

        var body: some View {
            ZStack(alignment: .center) {
                focusLine.offset(x: focus.mousePosition)
            }
            .frame(width: width, height: height, alignment: .leading)
        }

        var focusLine: some View {
            Rectangle()
                .frame(width: 1, height: height)
                .foregroundColor(Color.secondary).opacity(focus.showDataLabel ? 0.2 : 0)
        }
    }

    struct PlotBackgroundLinesAndLabels: View {

        @ScaledMetric(relativeTo: .caption) private var fontSize = MWVerySmall.fontSize
        let min: Double
        let max: Double

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Divider().foregroundColor(.secondary)
                Spacer()
                Divider()
                Spacer()

                Divider().foregroundColor(.secondary)

                Divider()
                Spacer()
                Divider()
                Spacer()
                Divider().foregroundColor(.secondary)
            }
            .overlay(text)
        }

        var text: some View {
            VStack(alignment: .leading, spacing: 0) {
                TextLabel(value: max).offset(y: -fontSize / 2)
                Spacer()
                TextLabel(value: min).offset(y: fontSize / 2).offset(x: -fontSize * 0.25)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: -fontSize)
        }

        struct TextLabel: View {

            var value: Double

            var body: some View {
                Text(String(format: "%1.f", value))
                    .padding(.trailing, 5)
                    .foregroundColor(.secondary)
                    .fontVerySmall()
            }
        }
    }
}
