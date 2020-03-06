//
//  UserNameViewController.swift
//  Ogiri
//
//  Created by kobayashi on 2019/10/13.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserNameViewController:
      UIViewController,
      UITextFieldDelegate{
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    let db = Firestore.firestore()//登録ユーザーの要素をdbに保存するため
    var emailText2: String?       //SignUpViewControllerでアドレスの値が渡っている
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
    }
    
    
    
    @IBAction func nameEditChanged(_ sender: UITextField) {
        self.validate()
    }
    
    @IBAction func termsButton(_ sender: Any) {
        let url = URL(string: "http://hari-blog.com/terms-of-service")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
    @IBAction func next(_ sender: Any) {
          addProfile()
        
        //navigationControllerでPlayViewControllerへ画面遷移
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID")  as! UITabBarController
        tabbarController.selectedIndex = 1
        self.navigationController?.pushViewController(tabbarController, animated: true)
    }
    
    private func validate() {
        
        // nilの場合はnextButtonを非活性に
            guard let nameText = userNameTextField.text else {
                    
                    self.nextButton.isEnabled = false
                      return
            }
        
            // 文字数が0の場合(""空文字)nextButtonを非活性に
            if nameText.count == 0 {
              
                self.nextButton.isEnabled = false
                return
            }
            
            // nilでないかつ0文字以上はnextButtonを活性に
            self.nextButton.isEnabled = true
    }
    
    
        //Firestore  新しいコレクションとドキュメントを作成
        private func addProfile() {
    
            var ref: DocumentReference? = nil
            
            //ドキュメント名を.uidで作成できるように.uidをuserIdに代入
            guard let userID = Auth.auth().currentUser?.uid else { fatalError() }
            
            //emailText2をアンラップ
            if let emailText2 = emailText2 {
                
                ref = db.collection("users").document(userID)
                
                ref?.setData ([
                    "emailAddress": emailText2,
                    "uid": userID,
                    "userName": userNameTextField.text ?? "noname",
                    "postedAt": "投稿されていません",
                    "comment1": "まだコメントはありません",
                    "comment2": "まだコメントはありません",
                    "comment3": "まだコメントはありません",
                    "comment4": "まだコメントはありません"
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
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
