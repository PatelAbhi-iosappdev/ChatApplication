//
//  AppDelegate.swift
//  Chat_App
//
//  Created by MACPC on 19/01/24.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }

            if let user = user {
                print("User is logged in. UID: \(user.uid)")
                self.showListViewController(for: user)
            } else {
                print("No user is logged in.")
                self.showLoginViewController()
            }
        }

        return true
    }

    func showLoginViewController() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func showListViewController(for firebaseUser: FirebaseAuth.User) {
        let listViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "list") as! ListViewController
        listViewController.firebaseUser = firebaseUser // Pass the Firebase user to your ListViewController
        let navigationController = UINavigationController(rootViewController: listViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)


}
}

