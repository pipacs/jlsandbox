//
//  AppDelegate.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        copyFOTAFiles()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

func copyFOTAFiles() {
    guard
        let resourcePath = Bundle.main.resourcePath,
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
        let fileNames = try? FileManager.default.contentsOfDirectory(atPath: resourcePath)
    else {
        return
    }
    let bundleURL = Bundle.main.bundleURL
    for fileName in fileNames.filter({ $0.hasSuffix(".ufw") }) {
        let src = bundleURL.appendingPathComponent(fileName)
        let dst = documentsURL.appendingPathComponent(fileName)
        try? FileManager.default.copyItem(at: src, to: dst)
    }
}
