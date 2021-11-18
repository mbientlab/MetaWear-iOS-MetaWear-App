//  Created by Ryan Ferrell on 8/8/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

/// Naive implementation using Canvas (accelerated) in Monterey/iOS 15 and CoreGraphics in prior releases
struct ScrollingStaticGraph: View {

    @StateObject var controller: ScrollingStaticGraphController

    let width: CGFloat
    let height: CGFloat = .detailsGraphHeight
    let dotSize: CGFloat = Self.getDotSize()

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .topLeading) {
#if os(iOS)
                if Self.useLazyRenderingWorkaround { lazyRenderingWorkaround } else { scrollView }

                FocusedPoints(width: width, height: height, dotSize: dotSize, controller: controller)
                    .opacity(showGraph ? 1 : 0)
#else
                scrollView
                FocusedPoints(width: width, height: height, dotSize: dotSize, controller: controller)
#endif
            }
            .frame(width: width)
            .padding(.vertical, 8)
            .environmentObject(controller)
            .environment(\.scrollProxy, proxy)
        }
    }

    var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
#if os(macOS) && !targetEnvironment(macCatalyst)
            HorizontalScrollOffset(delegate: controller, coordinateSpace: .localGraphScrollView)
#endif
            plottingMethod
                .frame(width: CGFloat(controller.displayedPoints.endIndex) * dotSize, height: height)
                .background(scrollTags)
        }
        .background(PlotBackgroundLinesAndLabels(min: controller.yMin, max: controller.yMax))
        .background(Color.plotBackground)
        .frame(width: width, height: height)
        .coordinateSpace(name: CoordinateSpace.Names.LocalGraphScrollView)
    }

    @ViewBuilder var plottingMethod: some View {
        if #available(macOS 12.0, iOS 15.0, *) {
            CanvasGPUPlot(width: width, height: height, dotSize: dotSize)
        } else {
            LegacyPlot(width: width, height: height, dotSize: dotSize)
        }
    }

    var scrollTags: some View {
        HStack {
            Color.clear.frame(width: 0.1).id("start")
            Spacer()
            Color.clear.frame(width: 0.1).id("end")
        }.hidden()
    }

    static func getDotSize() -> CGFloat {
        if #available(macOS 12.0, iOS 15.0, *) { return 2.5 }
        else { return 3 }
    }

    // MARK: - iOS Lazy Rendering on Scroll
    ///
    /// Issue: In iOS 14, several >3000 data point plots can degrade scroll view performance.
    /// A LazyVStack actually is less performant than the current eager implementation.
    ///
    /// Workaround: With more than 2 graphs, this conditionally removes the plots from
    /// the view hierarchy when scrolled out of view. There is a slight hitch during removal,
    /// but otherwise performance is restored.

#if os(iOS)
    @Environment(\.contentHeight) private var contentHeight
    @State private var showGraph = true
    private static var totalGraphs = 0
    private static let totalGraphLimit = 2
    private static let useLazyRenderingWorkaround: Bool = {
        if #available(iOS 15.0, *) { return false } // GPU-based seems performant
        return UIDevice.current.userInterfaceIdiom == .phone
    }()

    private var lazyRenderingWorkaround: some View {
        Group {
            if showGraph { scrollView } else { revealGraphButton }
        }
        .frame(width: width, height: height)
        .onAppear { Self.totalGraphs += 1 }
        .onDisappear { Self.totalGraphs -= 1 }

        // Measure offset in scroll view
        .background(GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .iOSDetailScrollView), perform: hideGraphForSmootherScrolling)
        })
    }

    private var revealGraphButton: some View {
        Button { withAnimation { showGraph = true } } label: {
            SFSymbol.refresh.image()
                .font(.largeTitle)
        }
    }

    private func hideGraphForSmootherScrolling(_ frame: CGRect) {
        guard showGraph, Self.totalGraphs > Self.totalGraphLimit else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            guard showGraph, Self.totalGraphs > Self.totalGraphLimit else { return }
            let isNotVisible = frame.minY > contentHeight || frame.maxY < 0
            if isNotVisible, showGraph { showGraph = false }
        }
    }
#endif

}

// MARK: - Plot Methods

private extension ScrollingStaticGraph {

    @available(macOS 12.0, iOS 15.0, *)
    struct CanvasGPUPlot: View {

        @EnvironmentObject private var controller: ScrollingStaticGraphController
        let width: CGFloat
        let height: CGFloat
        var dotSize: CGFloat

        var body: some View {
            Canvas(opaque: false, colorMode: .nonLinear, rendersAsynchronously: false) { context, size in
                func makePoint(x: CGFloat, y: CGFloat) -> Path {
                    Path(ellipseIn: .init(origin: CGPoint(x: x, y: y), size: .init(width: dotSize, height: dotSize)))
                }

                controller.displayedPoints.forEach { timepoint in
                    timepoint.heights.indices.forEach { seriesIndex in

                        let x = timepoint.x * dotSize
                        let relativeY = 1 - (timepoint.heights[seriesIndex] / controller.rangeY * height)  // Flip for coordinate system
                        let offsetToMiddle = (height / 2) - 1.5
                        let y = relativeY + offsetToMiddle

                        let path = makePoint(x: x, y: y)
                        context.fill(path, with: .color(controller.seriesColors[seriesIndex]))
                    }
                }
            }
        }
    }

    struct LegacyPlot: View {
        @EnvironmentObject private var controller: ScrollingStaticGraphController
        let width: CGFloat
        let height: CGFloat
        var dotSize: CGFloat

        var body: some View {
            if controller.displayedPoints.endIndex > 1000 {
                LazyHStack(alignment: .bottom, spacing: 0) { plot }
            } else {
#if os(iOS)
                LazyHStack(alignment: .bottom, spacing: 0) { plot }
#else
                HStack(alignment: .bottom, spacing: 0) { plot }
#endif
            }
        }

        var plot: some View {
            ForEach(controller.displayedPoints) { timepoint in
                ZStack(alignment: .top) {
                    ForEach(timepoint.heights.indices) { index in
                        Circle()
                            .frame(width: dotSize, height: dotSize)
                            .foregroundColor(controller.seriesColors[index])
                            .offset(y: legacyOffsetY(value: timepoint.heights[index]))
                    }
                }
                .frame(width: dotSize, height: height, alignment: .bottom)
            }
        }

        private func legacyOffsetY(value: CGFloat) -> CGFloat {
            let relativeValue = 1 - (value / (controller.rangeY / 2) ) // Flip for coordinate system
            return relativeValue * (height/2) - (height)
        }
    }
}

// MARK: - Scrolling

private extension ScrollingStaticGraph {

    struct ScrollButtons: View {
        @Environment(\.scrollProxy) private var scroller

        var body: some View {
            HStack {
                Button { scrollToStart() } label: { SFSymbol.start.image() }

                Spacer()

                Button { scrollToEnd() } label: { SFSymbol.end.image() }
            }
            .fontSmall()
            .padding(.trailing, .detailBlockContentPadding)
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                scrollToEnd()
            } }
        }

        func scrollToStart() {
            withAnimation {
                scroller?.scrollTo("start", anchor: .leading)
            }
        }

        func scrollToEnd() {
            withAnimation {
                scroller?.scrollTo("end", anchor: .trailing)
            }
        }
    }
}


// MARK: - Plot Components

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

}

// MARK: - Focused Points

extension ScrollingStaticGraph {

    struct FocusedPoints: View {

        let width: CGFloat
        let height: CGFloat
        init(width: CGFloat, height: CGFloat, dotSize: CGFloat, controller: ScrollingStaticGraphController) {
            self.width = width
            self.height = height
            self.mouse = controller.mouse
            self.controller = controller
            self.dotSize = dotSize
        }
        @ObservedObject var mouse: ScrollingStaticGraphController.MouseVM
        let controller: ScrollingStaticGraphController
        var dotSize: CGFloat

        var body: some View {
#if os(macOS) && !targetEnvironment(macCatalyst)
            macOS
#else
            iOS  // Stand-in for hover line (not supported currently)
#endif
        }

        var iOS: some View {
            VStack(alignment: .leading) {
                Rectangle()
                    .frame(height: height).hidden()
                    .padding(.top, .cardVSpacing)

                ScrollButtons()
                    .padding(.leading, .detailBlockContentPadding)
            }
            .frame(width: width)
        }

        var macOS: some View {
            VStack(alignment: .leading) {

                // Line
                ZStack(alignment: .center) {
                    focusLine
                        .offset(x: mouse.position)
                }
                .frame(width: width, height: height, alignment: .leading)
                .whenHoveredAtPoint { controller.mouseMoved(to: $0, width: width, dotSize: dotSize) }

                // Spacer for data labels that are overlaid below
                YSpacer(controller: controller)
                    .hidden()
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)
                    .overlay(ScrollButtons().offset(x: 7, y: 5), alignment: .top)
            }
            // Data labels rendered in Overlay to avoid view dimensions calculations for less CPU usage
            .overlay(DataLabels(width: width - 20, controller: controller)
                        .offset(x: dataLabelXOffset, y: dataLabelYOffset)
                        .opacity(mouse.show ? 1 : 0), alignment: .bottom)
        }
        @Environment(\.sizeCategory) private var typeSize
        private var dataLabelXOffset: CGFloat {
            if typeSize.isAccessibilityCategory { return 10 }
            if controller.seriesNames.endIndex > 3 { return -10 }
            else { return 20 }
        }

        private var dataLabelYOffset: CGFloat {
            if typeSize.isAccessibilityCategory { return 10 }
            if controller.seriesNames.endIndex > 3 { return -10 }
            else { return 10 }
        }

        var focusLine: some View {
            Rectangle()
                .frame(width: 1, height: height)
                .foregroundColor(Color.gray).opacity(mouse.show ? 1 : 0)
        }
    }

}

// MARK: - Data Labels

private extension ScrollingStaticGraph.FocusedPoints {

    struct DataLabels: View {

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
                        HStack(spacing: .detailBlockContentPadding) {
                            ForEach(controller.seriesNames.indices.filter { $0 % 2 != 0 }, id: \.self) { index in
                                PointLabel(width: width, color: controller.seriesColors[index], index: index, focus: controller.focus)
                            }
                        }
                        HStack(spacing: .detailBlockContentPadding) {
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

    /// Performance workaround to correctly space the Y offset of the data labels overlay depending on DynamicType
    struct YSpacer: View {

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

        private var row: some View {
            HStack {
                Circle().frame(width: 1, height: typeSize.isAccessibilityCategory ? 25 : MWSmall.fontSize + 3)
                Text("Spacer").fontSmall()
            }
        }
    }
}
