//
//  SignUpViewController.swift
//  Ogiri
//
//  Created by kobayashi riku on 2019/08/26.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController:
      UIViewController,
      UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }

    
    
    
    
    
    @IBAction func next(_ sender: Any) {
        
        //メアドとパスをアプリ内に保存
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil{
            
                print(error as Any)
                           
                
            }else{
                
                // 次の画面へ遷移
                self.performSegue(withIdentifier: "toUserNameVC", sender: nil)
            
            }
            
        }
        
    }
    
    
    
    
    
    
    @IBAction func play(_ sender: Any) {
        
        Auth.auth().signInAnonymously() { (authResult, error) in

            let anonymousUser = authResult?.user
            print(anonymousUser)

        }
        
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
