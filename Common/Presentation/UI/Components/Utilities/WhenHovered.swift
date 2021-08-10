//
//  WhenHovered.swift
//  WhenHovered
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//
#if os(macOS)
import SwiftUI

extension View {
    /// Workaround for poor performance of native .onHover modifier, which often misses mouseEnter and mouseExit events.
    func whenHovered(_ mouseIsInside: @escaping (Bool) -> Void) -> some View {
        modifier(MouseInsideModifier(mouseIsInside))
    }
}

struct MouseInsideModifier: ViewModifier {

    let mouseIsInside: (Bool) -> Void

    init(_ mouseIsInside: @escaping (Bool) -> Void) {
        self.mouseIsInside = mouseIsInside
    }

    func body(content: Content) -> some View {
        content.background(GeometryReader { proxy in
            MouseInsideRepresentable(mouseIsInside: mouseIsInside, frame: proxy.frame(in: .global))
        })
    }

    private struct MouseInsideRepresentable: NSViewRepresentable {

        let mouseIsInside: (Bool) -> Void
        let frame: NSRect

        func makeNSView(context: Context) -> HoverView {
            HoverView(frame: frame, mouseIsInside: mouseIsInside)
        }

        func updateNSView(_ nsView: HoverView, context: Context) {
            nsView.isEnabled = context.environment.isEnabled
        }
    }
}

extension MouseInsideModifier {

    class HoverView: NSView {

        var isEnabled: Bool = true
        let mouseIsInside: (Bool) -> Void

        init(frame: NSRect, mouseIsInside: @escaping (Bool) -> Void) {
            self.mouseIsInside = mouseIsInside
            super.init(frame: frame)

            let options: NSTrackingArea.Options = [
                .mouseEnteredAndExited,
                .inVisibleRect,
                .activeInKeyWindow
            ]

            let trackingArea = NSTrackingArea(rect: frame, options: options, owner: self, userInfo: nil)

            addTrackingArea(trackingArea)
        }

        required init?(coder: NSCoder) { fatalError("HoverView") }
    }
}

extension MouseInsideModifier.HoverView {

    override func mouseEntered(with event: NSEvent) {
        if isEnabled { mouseIsInside(true) }
    }

    override func mouseExited(with event: NSEvent) {
        mouseIsInside(false)
    }

    override func removeFromSuperview() {
        trackingAreas.forEach { removeTrackingArea($0) }
        super.removeFromSuperview()
    }
}
#endif
