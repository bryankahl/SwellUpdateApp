//
//  LoginViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/22/24.
//

import Foundation
import UIKit
import FirebaseAuth

// View controller to handle user login functionality.
class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField! // Text field for the user's email input.
    @IBOutlet weak var passwordTextField: UITextField! // Text field for the user's password input.

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: Any) {
        // Ensure both email and password fields are filled out.
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show an alert if either field is empty.
            let alert = UIAlertController(title: "Error", message: "Please enter both email and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }

        // Firebase login logic.
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Display an error alert if login fails.
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            // Navigate to the main screen upon successful login.
            DispatchQueue.main.async {
                self.transitionToMainScreen()
            }
        }
    }

    @IBAction func signupButtonTapped(_ sender: Any) {
        // Functionality to navigate to the signup screen can be added here if needed.
    }

    // MARK: - Navigation
    func transitionToMainScreen() {
        // Transition to the main tab bar controller after login.
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") else {
            return
        }
        // Set the tab bar controller as the root view controller.
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a gesture recognizer to dismiss the keyboard when tapping outside of text fields.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // Dismiss the keyboard when the user taps outside the text fields.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
