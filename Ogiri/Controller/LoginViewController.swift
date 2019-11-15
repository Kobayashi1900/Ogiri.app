//
//  LoginViewController.swift
//  Ogiri
//
//  Created by kobayashi riku on 2019/10/28.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController:
      UIViewController,
      UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var emailText: String?
    var passwordText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }
    

    @IBAction func login(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           
            if error != nil {
            
                print("ログインできませんでした")
                
            }else {
                
                print("ログインできました")
                
                //navigationControllerで画面遷移
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID")  as! UITabBarController

                self.navigationController?.pushViewController(tabbarController, animated: true)

            }
            
        }
    
  }
    
    @IBAction func emailEditChanged(_ sender: UITextField) {
        
        self.emailText = sender.text
        self.validate()
        
    }
    
    @IBAction func passwordEditChanged(_ sender: UITextField) {
        
        self.passwordText = sender.text
        self.validate()
        
    }
    
    private func validate() {
        
        // nilの場合は「次へ」を非活性に
        guard let emailText = self.emailText,
            let passwordText = self.passwordText else {
                    
                    self.loginButton.isEnabled = false
                      return
                      
            }
        
            // 文字数が0の場合(""空文字)次へを非活性に
        if emailText.count == 0 || passwordText.count == 0 {
              
                self.loginButton.isEnabled = false
                return
              
            }
            
            // nilでないかつ0文字以上は次へを活性に
            self.loginButton.isEnabled = true
        
    }
    
    //タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    //リターンでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
    }
    
}

