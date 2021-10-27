//
//  AppDelegate.swift
//  MetaWearApp
//
//  Created by Laura Kassovic on 1/19/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let root = AppRoot()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        root.applicationWillFinishLaunching(application, options: launchOptions)
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let bar = UINavigationBar.appearance()
        bar.tintColor = UIColor(.accentColor)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}

