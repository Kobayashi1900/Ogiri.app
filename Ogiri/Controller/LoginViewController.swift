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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailtextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    

    @IBAction func login(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailtextField.text!, password: passwordTextField.text!) { (user, error) in
           
            if error != nil {
            
                print("ログインできませんでした")
                
            }else {
                
                print("ログインできました")
                
                //navigationControllerで画面遷移
                let TimeLineVC = self.storyboard?.instantiateViewController(withIdentifier: "tlvc")  as! TimeLineViewController

                self.navigationController?.pushViewController(TimeLineVC, animated: true)

            }
            
        }
        
//        if let email = emailtextField.text, let password = passwordTextField.text {
//
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
//
//                //navigationControllerで画面遷移
//                    let TimeLineVC = self?.storyboard?.instantiateViewController(withIdentifier: "tlvc")  as! TimeLineViewController
//
//
//                    self?.navigationController?.pushViewController(TimeLineVC, animated: true)
//
//
//        }
//
//        }
    
        
        
        
    
  }
    
}

