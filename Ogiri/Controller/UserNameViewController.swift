//
//  UserNameViewController.swift
//  Ogiri
//
//  Created by kobayashi riku on 2019/10/13.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit

class UserNameViewController:
      UIViewController,
      UITextFieldDelegate{
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self

    }
    

    @IBAction func next(_ sender: Any) {
        
        
        
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
