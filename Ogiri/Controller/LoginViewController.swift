//
//  LoginViewController.swift
//  Ogiri
//
//  Created by kobayashi riku on 2019/10/27.
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
    
        Auth.auth().signIn(withEmail: emailtextField.text!, password: passwordTextField.text!) { [weak self] user, error in
      guard let strongSelf = self else { return }
      // [START_EXCLUDE]
      strongSelf.hideSpinner {
        if let error = error {
          strongSelf.showMessagePrompt(error.localizedDescription)
          return
        }
        strongSelf.navigationController?.popViewController(animated: true)
      }
      // [END_EXCLUDE]
    }
    
    }
    
}
