//
//  SceneDelegate.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/22/24.
//

import UIKit
import FirebaseAuth

// The SceneDelegate manages the app's window and its root view controller.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow? // The main window displaying the app's UI.

    // Called when the scene connects to the app session.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // Check if the user is already logged in via Firebase Authentication.
        if Auth.auth().currentUser != nil {
            // User is logged in, show the main app interface (e.g., TabBarController).
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            window.rootViewController = tabBarController
        } else {
            // User is not logged in, show the login screen.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            window.rootViewController = loginViewController
        }

        // Make the window visible and assign it to the `window` property.
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - Scene Lifecycle Methods (Optional)
    // These methods allow the app to respond to changes in the scene's lifecycle.

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the system.
        // This occurs shortly after the scene enters the background or its session is discarded.
        // Use this method to release resources tied to this scene.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart tasks paused (or not started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene moves from an active state to an inactive state.
        // This may occur due to temporary interruptions (e.g., an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data and release shared resources.
    }

    // Ensures the app stays in portrait orientation.
    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation: UIInterfaceOrientation, traitCollection: UITraitCollection) {
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

