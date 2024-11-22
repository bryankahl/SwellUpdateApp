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

class SignupViewController: UIViewController
{
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
                      let username = usernameTextField.text, !username.isEmpty,
                      let password = passwordTextField.text, !password.isEmpty else {
                    let alert = UIAlertController(title: "Error", message: "Please fill out all fields.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                // Firebase Sign-Up Logic
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }

                    // Add user to Firestore
                    guard let user = authResult?.user else { return }
                    let db = Firestore.firestore()
                    db.collection("Users").document(user.uid).setData([
                        "email": email,
                        "username": username
                    ]) { error in
                        if let error = error {
                            print("Error saving user data: \(error.localizedDescription)")
                        } else {
                            print("User data successfully saved!")
                        }
                    }

                    // Navigate back to Login screen
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
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

    

