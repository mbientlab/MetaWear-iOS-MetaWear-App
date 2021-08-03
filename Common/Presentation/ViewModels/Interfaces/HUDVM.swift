//  © 2021 Ryan Ferrell. github.com/importRyan

#if os(iOS)
import MBProgressHUD
import UIKit
public typealias Window = UIWindow
#else
public typealias Window = NSWindow
#endif

public protocol HUDVM {

    /// To use key window, pass nil.
    func presentHUD(mode: MBProgressHUDMode, text: String, in window: Window?)

    func updateProgressHUD(percentage: Float)

    /// To not overwrite text, pass nil. Default close delay is 2 seconds.
    func closeHUD(finalMessage: String?, delay: Double)

    /// To not overwrite text, pass nil.
    func updateHUD(mode: MBProgressHUDMode, newText: String?)
}

public extension HUDVM {

    /// To not overwrite text, pass nil. To use key window, pass nil.
    func presentHUD(mode: MBProgressHUDMode = .indeterminate, text: String = "", in window: Window?) {
        presentHUD(mode: mode, text: text, in: window)
    }

    /// To use key window, pass nil.
    func presentProgressHUD(label: String = "Updating...", in window: Window?) {
        presentHUD(mode: .determinateHorizontalBar, text: label, in: window)
    }

    /// To not overwrite text, pass nil. Default delay is 2 seconds.
    func closeHUD(finalMessage: String? = nil, delay: Double = 2) {
        closeHUD(finalMessage: finalMessage, delay: delay)
    }

}
