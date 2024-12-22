//
//  SignupViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/22/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

// View controller for user signup functionality.
class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!      // Text field for user's email.
    @IBOutlet weak var usernameTextField: UITextField!   // Text field for user's username.
    @IBOutlet weak var passwordTextField: UITextField!   // Text field for user's password.

    // MARK: - Actions
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        // Validate that all fields are filled out.
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show an alert if fields are missing.
            let alert = UIAlertController(title: "Error", message: "Please fill out all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }

        // Firebase Sign-Up Logic
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle errors during user creation and show an alert.
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            // Successfully created user; save user data to Firestore.
            guard let user = authResult?.user else { return }
            let db = Firestore.firestore()
            db.collection("Users").document(user.uid).setData([
                "email": email,
                "username": username
            ]) { error in
                if let error = error {
                    // Log any errors when saving user data to Firestore.
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data successfully saved!")
                }
            }

            // Navigate back to the login screen after successful signup.
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a gesture recognizer to dismiss the keyboard when tapping outside of text fields.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // Dismiss the keyboard when the view is tapped.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
