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
        ScrollViewReader { proxy in
            VStack(spacing: 5) {
                ScrollButtons(scroller: proxy)
                graph
            }
        }
    }

    var graph: some View {
        ZStack(alignment: .topLeading) {
            ScrolledGraph(controller: controller, width: width, height: height)
                .frame(width: width, height: height)

#if os(macOS) && !targetEnvironment(macCatalyst)
            FocusedPointOverlay(width: width, height: height, controller: controller)
#endif
        }
        .padding(.vertical, 8)
    }

    private struct ScrollButtons: View {
        let scroller: ScrollViewProxy

        var body: some View {
            HStack {
                Button { withAnimation {
                    scroller.scrollTo("start", anchor: .leading)
                } } label: { SFSymbol.start.image() }

                Spacer()

                Button { withAnimation {
                    scroller.scrollTo("end", anchor: .trailing)
                } } label: { SFSymbol.end.image() }
            }
            .fontSmall()
            .padding(.horizontal, .detailBlockContentPadding)
        }
    }

}

// MARK: - Graph

extension ScrollingStaticGraph {

    /// Graph points
    struct ScrolledGraph: View {

        @ObservedObject var controller: ScrollingStaticGraphController
        let width: CGFloat
        let height: CGFloat

        var body: some View {
            ScrollView(.horizontal, showsIndicators: true) {
#if os(macOS) && !targetEnvironment(macCatalyst)
                ScrollOffsetMeasurer()
#endif
                Graph(controller: controller, width: width, height: height)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in controller.updateScrollOffset(offset.x) }
            .background(PlotBackgroundLinesAndLabels(min: controller.yMin, max: controller.yMax))
            .background(Color.plotBackground)
        }
    }

    struct Graph: View {

        @ObservedObject var controller: ScrollingStaticGraphController
        let width: CGFloat
        let height: CGFloat
        let pointSize = CGSize(width: ScrollingStaticGraph.dotSize, height: ScrollingStaticGraph.dotSize)

        var body: some View {
            HStack(spacing: 0) {
                Color.clear.frame(width: 0.1).id("start")
                if #available(macOS 12.0, iOS 15.0, *) {
                    canvasGPU
                } else if controller.displayedPoints.endIndex > 1400 {
                    LazyHStack(alignment: .bottom, spacing: 0) {
                        legacyCPU
                    }
                } else {
                    HStack(alignment: .bottom, spacing: 0) {
                        legacyCPU
                    }
                }
                Color.clear.frame(width: 0.1).id("end")
            }
            .frame(width: CGFloat(controller.displayedPoints.endIndex) * ScrollingStaticGraph.dotSize, height: height)
        }

        @available(macOS 12.0, iOS 15.0, *)
        var canvasGPU: some View {
            Canvas(opaque: false, colorMode: .nonLinear, rendersAsynchronously: false) { context, size in
                func makePoint(x: CGFloat, y: CGFloat) -> Path {
                    Path(ellipseIn: .init(origin: CGPoint(x: x, y: y), size: pointSize))
                }

                controller.displayedPoints.forEach { timepoint in
                    timepoint.heights.indices.forEach { seriesIndex in

                        let x = timepoint.x * ScrollingStaticGraph.dotSize
                        let y = (timepoint.heights[seriesIndex] / controller.rangeY * height) + (height / 2) - 1.5

                        let path = makePoint(x: x, y: y)
                        context.fill(path, with: .color(controller.seriesColors[seriesIndex]))
                    }
                }
            }
        }

        var legacyCPU: some View {
            ForEach(controller.displayedPoints) { timepoint in
                ZStack(alignment: .bottom) {
                    ForEach(timepoint.heights.indices) { index in
                        Circle().frame(width: ScrollingStaticGraph.dotSize, height: ScrollingStaticGraph.dotSize)
                            .foregroundColor(controller.seriesColors[index])
                            .offset(y: legacyOffsetY(value: timepoint.heights[index]))
                    }
                }
                .frame(width: ScrollingStaticGraph.dotSize, height: height, alignment: .bottom)
            }
        }

        func legacyOffsetY(value: CGFloat) -> CGFloat {
            let relativeValue = value / controller.rangeY
            return relativeValue * height - (height / 2)
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


// MARK: - Overlay Components

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

    struct FocusedPointOverlay: View {

        let width: CGFloat
        let height: CGFloat
        init(width: CGFloat, height: CGFloat, controller: ScrollingStaticGraphController) {
            self.width = width
            self.height = height
            self.mouse = controller.mouse
            self.controller = controller
        }
        @ObservedObject var mouse: ScrollingStaticGraphController.MouseVM
        let controller: ScrollingStaticGraphController

        var body: some View {
            VStack(alignment: .leading) {

                // Line
                ZStack(alignment: .center) {
                    focusLine
                        .offset(x: mouse.position)
                }
                .frame(width: width, height: height, alignment: .leading)
                .whenHoveredAtPoint { controller.mouseMoved(to: $0, width: width, dotSize: ScrollingStaticGraph.dotSize) }

                // Spacer for data labels that are overlaid below
                FocusPointDataLabelsSpacer(controller: controller)
                    .padding(.top, 10)
                    .hidden()
            }
            // Data labels rendered in Overlay to avoid view dimensions calculations for less CPU usage
            .overlay(FocusedPointDataLabels(width: width - 20, controller: controller)
                        .offset(x: 20, y: 10)
                        .opacity(mouse.show ? 1 : 0), alignment: .bottom)
        }

        var focusLine: some View {
            Rectangle()
                .frame(width: 1, height: height)
                .foregroundColor(Color.gray).opacity(mouse.show ? 1 : 0)
        }
    }
}

// MARK: - Data Labels

extension ScrollingStaticGraph {

    struct FocusPointDataLabelsSpacer: View {

        @Environment(\.sizeCategory) private var typeSize
        let controller: ScrollingStaticGraphController

        var body: some View {
            if typeSize.isAccessibilityCategory {
                VStack {
                    ForEach(controller.seriesNames, id: \.self) { _ in
                        row
                    }
                }
            } else if controller.seriesNames.endIndex > 3 {
                VStack {
                    row
                    row
                }
            } else {
                row
            }
        }

        var row: some View {
            HStack {
                Circle().frame(width: 1, height: typeSize.isAccessibilityCategory ? 25 : 11)
                Text("Spacer").fontSmall()
            }
        }
    }

    struct FocusedPointDataLabels: View {

        let width: CGFloat
        let controller: ScrollingStaticGraphController

        @Environment(\.sizeCategory) private var typeSize

        var body: some View {
            VStack(alignment: .center) {

                if typeSize.isAccessibilityCategory {
                    VStack {
                        ForEach(controller.seriesNames.indices) { index in
                            PointLabel(width: width, color: controller.seriesColors[index], index: index, focus: controller.focus)
                        }
                    }
                } else if controller.seriesNames.endIndex > 3 {
                    VStack {
                        HStack {
                            ForEach(controller.seriesNames.indices.filter { $0 % 2 != 0 }, id: \.self) { index in
                                PointLabel(width: width, color: controller.seriesColors[index], index: index, focus: controller.focus)
                            }
                        }
                        HStack {
                            ForEach(controller.seriesNames.indices.filter { $0 % 2 == 0 }, id: \.self) { index in
                                PointLabel(width: width, color: controller.seriesColors[index], index: index, focus: controller.focus)
                            }
                        }
                    }
                } else {
                    HStack {
                        ForEach(controller.seriesNames.indices) { index in
                            PointLabel(width: width, color: controller.seriesColors[index], index: index, focus: controller.focus)
                        }
                    }
                }
            }
            .frame(width: width, alignment: .top)
        }

        struct PointLabel: View {

            let width: CGFloat
            let color: Color
            let index: Int
            let focus: ScrollingStaticGraphController.FocusedPointsVM

            @Environment(\.sizeCategory) private var typeSize

            var body: some View {
                HStack {
                    Circle()
                        .fill(color).frame(width: typeSize.isAccessibilityCategory ? 25 : 11, height: typeSize.isAccessibilityCategory ? 25 : 11)

                    Value(index: index, focus: focus)
                }
                .frame(width: width / CGFloat(focus.points.endIndex), alignment: .leading)
            }

            struct Value: View {
                let index: Int
                @ObservedObject var focus: ScrollingStaticGraphController.FocusedPointsVM

                var body: some View {
                    Text(focus.points[index])
                        .fontSmall(monospacedDigit: true)
                }
            }
        }
    }
}
