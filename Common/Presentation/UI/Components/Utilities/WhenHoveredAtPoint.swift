//  Copyright © 2021 MbientLab. All rights reserved.
//


import SwiftUI

extension View {

    func whenHoveredAtPoint(_ mouseLocation: @escaping (CGPoint?) -> Void) -> some View {
#if os(macOS) && !targetEnvironment(macCatalyst)
        modifier(MouseInsideCGPointModifier(mouseLocation))
#else
        self
#endif
    }
}

#if os(macOS)
struct MouseInsideCGPointModifier: ViewModifier {

    let mouseLocation: (CGPoint?) -> Void

    init(_ mouseLocation: @escaping (CGPoint?) -> Void) {
        self.mouseLocation = mouseLocation
    }

    func body(content: Content) -> some View {
        content.background(GeometryReader { proxy in
            MouseInsideRepresentable(mouseLocation: mouseLocation, frame: proxy.frame(in: .global))
        })
    }

    private struct MouseInsideRepresentable: NSViewRepresentable {

        let mouseLocation: (CGPoint?) -> Void
        let frame: NSRect

        func makeNSView(context: Context) -> HoverView {
            HoverView(frame: frame, mouseLocation: mouseLocation)
        }

        func updateNSView(_ nsView: HoverView, context: Context) {
            nsView.isEnabled = context.environment.isEnabled
        }
    }
}

extension MouseInsideCGPointModifier {

    class HoverView: NSView {

        var isEnabled: Bool = true
        let mouseLocation: (CGPoint?) -> Void

        init(frame: NSRect, mouseLocation: @escaping (CGPoint?) -> Void) {
            self.mouseLocation = mouseLocation
            super.init(frame: frame)

            let options: NSTrackingArea.Options = [
                .mouseMoved,
                .inVisibleRect,
                .mouseEnteredAndExited,
                .activeInKeyWindow
            ]

            let trackingArea = NSTrackingArea(rect: frame, options: options, owner: self, userInfo: nil)

            addTrackingArea(trackingArea)
        }

        required init?(coder: NSCoder) { fatalError("HoverView") }
    }
}

extension MouseInsideCGPointModifier.HoverView {

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard isEnabled else { return }
        mouseLocation(self.convert(event.locationInWindow, from: window?.contentView))
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard isEnabled else { return }
        mouseLocation(nil)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        guard isEnabled else { return }
        mouseLocation(self.convert(event.locationInWindow, from: window?.contentView))
    }

    override func removeFromSuperview() {
        trackingAreas.forEach { removeTrackingArea($0) }
        super.removeFromSuperview()
    }
}
#endif
