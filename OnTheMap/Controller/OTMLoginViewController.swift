//
//  OTMLoginViewController.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/7/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AccountKit


// MARK: - OTMLoginViewController: UIViewController
class OTMLoginViewController: UIViewController {
    
    // MARK: Properties
    var isKeyboardOnScreen = false
    
    
    // MARK: Outlets    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // Facebook
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(accessTokenDidChange(_:)), name: .FBSDKAccessTokenDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareUI()
        self.subscribeKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeKeyboardNotification()
        NotificationCenter.default.removeObserver(self, name: .FBSDKAccessTokenDidChange, object: nil)
    }
    
    
    // MARK: Helper
    
    func completeLogin() {
        
        debugLabel.text = ""
        
        let navController = storyboard?.instantiateViewController(withIdentifier: "OTMNavigationController") as! UINavigationController
        //present(navController, animated: true, completion: nil)
        present(navController, animated: true) {
            performUIUpdatesOnMain {
                self.isLoginViewLoading(false)
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        isLoginViewLoading(true)
        
        if let userName = emailTextField.text,
        let password = passwordTextField.text {
    
        UDACITYClient.sharedInstance().authenticateWithUserNameAndPassword(self, userName, password){ (success, error) in
                if success {
                    performUIUpdatesOnMain {
                        self.completeLogin()
                    }
                } else {
                   let message = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    performUIUpdatesOnMain {
                        self.isLoginViewLoading(false)
                        errorAlertView(message, self)
                    }
                }
            }
        }
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://udacity.com/account/auth#!/signup") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    
    @IBAction func backgroundTapped(_ sender: Any) {
        resignIfFirstResponder(self.emailTextField)
            resignIfFirstResponder(self.passwordTextField)
    }
}


// MARK: - OTMLoginViewController: UITexFieldDelegate

extension OTMLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.passwordTextField {
            self.isKeyboardOnScreen = false
            view.frame.origin.y = 0
            self.loginButtonPressed(textField)
            
            return textField.resignFirstResponder()
        }
        
        return false
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            self.isKeyboardOnScreen = false
            view.frame.origin.y = 0
        }
    }
}


// MARK: - OTMLoginViewController: FBSDKLoginButtonDelegate

extension OTMLoginViewController: FBSDKLoginButtonDelegate {
    
    @objc func accessTokenDidChange(_ notification: Notification) {
        
        if let token = notification.userInfo![FBSDKAccessTokenChangeNewKey] {
            FBSDKAccessToken.setCurrent(token as! FBSDKAccessToken)
        }
    }
    
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        print("loginButtonWillLogin")
        
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        FBSDKAccessToken.setCurrent(nil)
        print("loginButtonDidLogOut")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        guard error == nil else {
            performUIUpdatesOnMain {
                errorAlertView(error.localizedDescription, self)
            }
            return
        }
        
        guard let result = result, !result.isCancelled else {
            performUIUpdatesOnMain {
                errorAlertView("Login is Canceled", self)
            }
            return
        }
        
        if let token = FBSDKAccessToken.current() {
            
            UDACITYClient.sharedInstance().authenticateWithFB(token, completionHandlerForAuthWithFB: { (success, error) in
                
                if success {
                    performUIUpdatesOnMain {
                        self.completeLogin()
                    }
                } else {
                    performUIUpdatesOnMain {
                        errorAlertView(error?.userInfo[NSLocalizedDescriptionKey] as! String, self)
                    }
                }
            })
        }
    }
}


// MARK: - OTMLoginViewController (UI)

extension OTMLoginViewController {
    
    func prepareUI() {
        fbLoginButton.loginBehavior = .web
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.isHidden = true
        activityIndicatorView.isHidden = true
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
    }
    
    func isLoginViewLoading(_ isLoading: Bool) {
        dimView.isHidden = !isLoading
        activityIndicatorView.isHidden = !isLoading
        view.endEditing(!isLoading)
        
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
}


// MARK: - OTMLoginViewController (configure keyboard position)

extension OTMLoginViewController {
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !isKeyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification) / 4
            self.isKeyboardOnScreen = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isKeyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification) / 4
            self.isKeyboardOnScreen = false
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        isKeyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        isKeyboardOnScreen = false
    }
}


// MARK: - OTMLoginViewController (Notification)
extension OTMLoginViewController {
    
    func subscribeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
    }
    
    func unsubscribeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}
