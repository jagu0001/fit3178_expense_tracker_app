//
//  LoginViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/21/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    var authHandle: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        authHandle = Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            guard user != nil else { return }
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard let authHandle = authHandle else { return }
        Auth.auth().removeStateDidChangeListener(authHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginAccount(_ sender: Any) {
        guard let email = emailTextField.text else {
            displayMessage(title: "Error", message: "Please enter an email")
            return
        }
        
        guard let password = passwordTextField.text else {
            displayMessage(title: "Error", message: "Please enter a password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayMessage(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
