//
//  DeviceDetailScreenHostingViews.swift
//  DeviceDetailScreenHostingViews
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import Combine

#if canImport(AppKit)

struct DeviceDetailScreenMacContainer: View {
    @StateObject var vc: DeviceDetailScreenSUIVC
    var chain: Namespace.ID

    var body: some View {
        DeviceDetailScreen(chain: chain)
            .onAppear { vc.start() }
            .onDisappear { vc.end() }
            .environmentObject(vc)
    }
}

#elseif canImport(UIKit)

import MetaWear

/// Wrap the SwiftUI shared details "table view" for use with a storyboard
class DeviceDetailScreenUIKitContainer: UIHostingController<DeviceDetailScreenUIKitContainer.Wrapped> {

    private var vc: DeviceDetailsCoordinator

    required init?(coder aDecoder: NSCoder) {
        var store: AppStore { (UIApplication.shared.delegate as! AppDelegate).store }
        self.vc = store.ui.makeDetailScreenVC(device: nil)
        let view = Wrapped(
            app: store,
            prefs: store.preferences,
            vc: vc as! DeviceDetailScreenSUIVC
        )
        super.init(coder: aDecoder, rootView: view)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vc.start()
        navigationController?.navigationBar.tintColor = UIColor(named: "AccentColor")

        // Workaround iPad bug where a SwiftUI ScrollView will slip underneath
        // without translucency applied

        if UIDevice.current.userInterfaceIdiom == .pad {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "AccentColor")!]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "AccentColor")!]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vc.end()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.tintColor = UIColor(named: "AccentColor")

    }

    /// Pass selected device from storyboard segue
    func setDevice(device: MetaWear) {
        vc.setDevice(device)
    }
}

extension DeviceDetailScreenUIKitContainer {

    /// Simply inject environment with objects from Mac's @main and MainWindow
    struct Wrapped: View {

        @ObservedObject var app: AppStore
        @ObservedObject var prefs: PreferencesStore
        @ObservedObject var vc: DeviceDetailScreenSUIVC
        @Namespace var chain

        @State private var keyboardIsShown = false
        @State private var keyboardHideMonitor: AnyCancellable? = nil
        @State private var keyboardShownMonitor: AnyCancellable? = nil

        var body: some View {
            DeviceDetailScreen(toast: vc.toast as! MWToastServerVM, chain: chain)
                .lineSpacing(6)
                .menuStyle(BorderlessButtonMenuStyle())
                .buttonStyle(BorderlessButtonStyle())
                .multilineTextAlignment(.leading)

                .environment(\.keyboardIsShown, keyboardIsShown)
                .onDisappear { dismantleKeyboarMonitors() }
                .onAppear { setupKeyboardMonitors() }

                .environment(\.fontFace, prefs.font)
                .environmentObject(vc)
                .environmentObject(app)
                .environmentObject(app.preferences)
        }


        func setupKeyboardMonitors() {
            keyboardShownMonitor = NotificationCenter.default
                .publisher(for: UIWindow.keyboardWillShowNotification)
                .sink { _ in if !keyboardIsShown { keyboardIsShown = true } }

            keyboardHideMonitor = NotificationCenter.default
                .publisher(for: UIWindow.keyboardWillHideNotification)
                .sink { _ in if keyboardIsShown { keyboardIsShown = false } }
        }

        func dismantleKeyboarMonitors() {
            keyboardHideMonitor?.cancel()
            keyboardShownMonitor?.cancel()
        }
    }
}

#endif
