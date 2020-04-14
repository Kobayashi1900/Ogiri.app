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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        if (UserDefaults.standard.object(forKey: "email") != nil){
            if (UserDefaults.standard.object(forKey: "password") != nil){
            
            self.emailTextField.text = (UserDefaults.standard.object(forKey: "email") as! String)
            self.passwordTextField.text = (UserDefaults.standard.object(forKey: "password") as! String)
            self.loginButton.isEnabled = true
            }
        }
    }
    

    @IBAction func login(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           
            if error != nil {
                let alert = UIAlertController(title: "ログインエラー",
                                              message: "メールアドレスまたはパスワードが違います。",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                print("ログインできませんでした")
            }else{
                print("ログインできました")
                
                //navigationControllerで画面遷移
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID")  as! UITabBarController

                self.navigationController?.pushViewController(tabbarController, animated: true)
            }
        }
  }
    
    @IBAction func emailEditChanged(_ sender: UITextField) {
        self.validate()
    }
    
    @IBAction func passwordEditChanged(_ sender: UITextField) {
        self.validate()
    }
    
    private func validate() {
        
        // nilの場合はloginButtonを非活性に
        guard let emailText = emailTextField.text,
            let passwordText = passwordTextField.text else {
                    
                    self.loginButton.isEnabled = false
                      return
            }
        
            //アドレスが0(""空文字)、パスワードが6文字より少ない場合nextButtonを非活性に
        if emailText.count == 0 || passwordText.count < 6 {
              
                self.loginButton.isEnabled = false
                return
            }
            
            //nilでないかつ0文字、6文字より多ければnextButtonを活性に
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
