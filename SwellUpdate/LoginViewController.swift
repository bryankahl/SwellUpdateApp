//
//  LoginViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/22/24.
//

import Foundation
import UIKit
import FirebaseAuth
import LocalAuthentication


class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    // Your outlets and actions will go here
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter both email and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        // Firebase login logic
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }

                    // Navigate to the main app screen
                    DispatchQueue.main.async {
                        self.transitionToMainScreen()
                    }
                }
    }
    @IBAction func signupButtonTapped(_ sender: Any) {
    }
    
    
    func transitionToMainScreen() {
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") else {
            return
        }
        // Set the TabBarController as the root view controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Add gesture recognizer to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
