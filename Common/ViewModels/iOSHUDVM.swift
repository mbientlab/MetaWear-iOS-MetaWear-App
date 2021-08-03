//  © 2021 Ryan Ferrell. github.com/importRyan

#if canImport(UIKit)
import UIKit
import MBProgressHUD

public class iOSHUDVM {

    private var keyWindow: UIWindow { UIApplication.firstKeyWindow()! }
    private(set) var hud: MBProgressHUD? = nil

}

extension iOSHUDVM: HUDVM {

    public func updateProgressHUD(percentage: Float) {
        hud?.progress = percentage
    }

    public func presentHUD(mode: MBProgressHUDMode = .indeterminate,
                           text: String,
                           in window: Window?) {
        self.hud = MBProgressHUD.showAdded(to: window ?? keyWindow, animated: true)
        self.hud?.mode = mode
        hud?.label.text = "Connecting..."
    }

    /// Passing nil for text will not override existing text
    public func updateHUD(mode: MBProgressHUDMode, newText: String?) {
        hud?.mode = mode
        if let text = newText {
            hud?.label.text = text
        }
    }

    public func closeHUD(finalMessage: String?, delay: Double) {
        hud?.mode = .text
        if let text = finalMessage {
            hud?.label.text = text
        }
        hud?.hide(animated: true, afterDelay: delay)
    }
}

#endif
