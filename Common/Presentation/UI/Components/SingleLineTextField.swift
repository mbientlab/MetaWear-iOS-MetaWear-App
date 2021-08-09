//
//  SingleLineTextField.swift
//  SingleLineTextField
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
import Combine

struct TextFieldConfig {
    var textColor: Color = .primary
    var font: FontFace
    let size: CGFloat
    var weight: NSFont.Weight = .regular
    var design: NSFontDescriptor.SystemDesign = .rounded
    var lineBreakMode: NSLineBreakMode = .byTruncatingMiddle
    var alignment: NSTextAlignment = .left

    static func largeDeviceStyle(face: FontFace) -> Self {
        self.init(font: face, size: 18)
    }
}

struct SingleLineTextField: NSViewControllerRepresentable {

    var initialText: String
    var config: TextFieldConfig

    let onCommit: ((String) -> Void)
    let onCancel: (() -> Void)

    func makeNSViewController(context: Context) -> SingleLineTextFieldVC {
        let vc = SingleLineTextFieldVC(
            initialText: initialText,
            font: config.font,
            size: config.size,
            alignment: config.alignment
        )

        vc.field.textColor = NSColor(config.textColor)
        vc.field.textContainer?.lineBreakMode = config.lineBreakMode
        vc.onCommit = onCommit
        vc.onCancel = onCancel
        return vc
    }

    func updateNSViewController(_ vc: SingleLineTextFieldVC,
                                context: Context) {
        vc.field.string = initialText
        vc.field.textColor = NSColor(config.textColor)
        vc.field.font = .adaptiveFont(for: config.font, size: config.size, weight: config.weight, design: config.design)
        switch config.alignment {
            case .left: vc.field.alignLeft(nil)
            case .right: vc.field.alignRight(nil)
            default: vc.field.alignCenter(nil)
        }
    }
}

final class SingleLineTextFieldVC: NSViewController {

    var initialText: String
    var onCommit: ((String) -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    var font: NSFont
    private var applyTextAlignment: NSTextAlignment
    private var subs: Set<AnyCancellable> = []

    let field = FatRoundInsertionCaretTextView(frame: .zero)
    let placeholder = NSTextField(string: "")

    init(initialText: String, font: FontFace, size: CGFloat, alignment: NSTextAlignment) {
        self.initialText = initialText
        self.font = .adaptiveFont(for: font, size: size)
        self.applyTextAlignment = alignment
        super.init(nibName: nil, bundle: nil)
    }

    override func resignFirstResponder() -> Bool {
        onCommit?(field.string)
        return super.resignFirstResponder()
    }

    override func removeFromParent() {
        onCommit?(field.string)
        field.trackingAreas.forEach { [weak self] in self?.field.removeTrackingArea($0) }
        super.removeFromParent()
    }

    override func loadView() {
        view = field
        configureTextField()
        configurePlaceholder()
        placeholder.isHidden = !field.string.isEmpty
        view.addSubview(placeholder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resignFirstResponderOnClickMonitor()
    }

    private func configureTextField() {
        field.delegate = self
        field.allowsUndo = false
        field.string = initialText
        field.font = font
        field.alignment = applyTextAlignment
        field.isContinuousSpellCheckingEnabled = false
        field.textContainer?.maximumNumberOfLines = 1
        field.textContainer?.widthTracksTextView = true
        field.backgroundColor = .clear
        field.importsGraphics = false
    }

    private func configurePlaceholder() {
        placeholder.font = font
        placeholder.textColor = .secondaryLabelColor
        placeholder.isBordered = false
        placeholder.backgroundColor = .clear
        placeholder.isSelectable = false
        placeholder.isEnabled = false
        placeholder.isEditable = false
    }

    private func resignFirstResponderOnClickMonitor() {
        NSApp.publisher(for: \.currentEvent)
            .filter { event in event?.type == NSEvent.EventType.leftMouseDown }
            .sink { [weak self] event in
                guard let self = self,
                      self.view.window?.firstResponder === self.field,
                      let location = event?.locationInWindow else { return }
                let localPoint = self.view.convert(location, from: nil)

                if !self.view.bounds.contains(localPoint) {
                    self.onCommit?(self.field.string)
                    self.view.window?.makeFirstResponder(self.view.window?.nextResponder)
                }
            }
            .store(in: &subs)


            NSApp.publisher(for: \.accessibilityFocusedUIElement)
                .sink { [weak self] element in
                    guard let self = self,
                          self.view.window?.firstResponder === self.field
                    else { return }

                    if (element as? SingleLineTextFieldVC) === self { return }
                    else {
                        self.onCommit?(self.field.string)
                        self.view.window?.makeFirstResponder(self.view.window?.nextResponder)
                    }
                }
                .store(in: &subs)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SingleLineTextFieldVC: NSTextViewDelegate {

    override func cancelOperation(_ sender: Any?) {
        onCommit?(field.string)
        onCancel?()
        view.window?.makeFirstResponder(nil)
    }

    func textView(_ view: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            onCommit?(view.string)
            view.window?.makeFirstResponder(nil)
            _ = self.resignFirstResponder()
            return true
        }
        return false
    }

    private func showOrHidePlaceholder() {
        if self.field.string.isEmpty, self.placeholder.isHidden {
            self.placeholder.isHidden = false
        } else if !self.placeholder.isHidden {
            self.placeholder.isHidden = true
        }
    }
}

class FatRoundInsertionCaretTextView: NSTextView {

    var caretWidth: CGFloat = 3

    private lazy var radius = caretWidth / 2
    private lazy var displayAdjustment = caretWidth - 1

    open override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {

        var rect = rect
        rect.size.width = caretWidth

        let path = NSBezierPath(roundedRect: rect,
                                xRadius: radius,
                                yRadius: radius)
        path.setClip()

        super.drawInsertionPoint(in: rect,
                                 color: NSColor.highlightColor,
                                 turnedOn: flag)
    }

    open override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout flag: Bool) {
        var rect = rect
        rect.size.width += displayAdjustment
        super.setNeedsDisplay(rect, avoidAdditionalLayout: flag)
    }
}
