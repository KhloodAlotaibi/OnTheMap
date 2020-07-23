//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Khlood on 7/14/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var UdacityLogo: UIImageView!
    @IBOutlet var myUsernameTextField: UITextField!
    @IBOutlet var myPasswordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var myActivityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        UdacityLogo.image = UIImage(named: "udacity")
    }
    
    @IBAction func myLoginButtonClicked(_ sender: Any) {
        setLoggingIn(true)
        if (myUsernameTextField.text!.isEmpty) || (myPasswordTextField.text!.isEmpty) {
            setLoggingIn(false)
            self.showAlert(title: "Error", message: "Both the email and password are required")
        }
        API.login(myUsernameTextField.text!, myPasswordTextField.text!) { (success, error) in 
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                guard error == nil else {
                    self.showAlert(title: "Error", message: "Error with request")
                    return
                }
                if !success {
                    self.showAlert(title: "Error", message: "Incorrect email or/and password")
                } else {
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                }
            }
        }
    }
    
    @IBAction func mySignupButtonClicked(_ sender: Any) {
        if let url = URL(string: "https://auth.udacity.com/sign-up") {
            UIApplication.shared.open(url)
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            myActivityIndicator.startAnimating()
        } else {
            myActivityIndicator.stopAnimating()
        }
        myUsernameTextField.isEnabled = !loggingIn
        myPasswordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signupButton.isEnabled = !loggingIn
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
