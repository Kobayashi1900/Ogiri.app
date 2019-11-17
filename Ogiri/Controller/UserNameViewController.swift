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
    
    var nameText: String?
    let db = Firestore.firestore()
    var emailText2: String?
    var passwordText2: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self

    }
    
    
    
    @IBAction func nameEditChanged(_ sender: UITextField) {
        
        self.nameText = sender.text
        self.validate()
        
    }
    
    
    
    @IBAction func next(_ sender: Any) {
        
          addProfile()
//        addAdaLovelace()
//        addAlanTuring()
//        getCollection()
        
        
    }
    
    private func validate() {
        
        // nilの場合は「次へ」を非活性に
            guard let nameTxt = self.nameText else {
                    
                    self.nextButton.isEnabled = false
                      return
                      
            }
        
            // 文字数が0の場合(""空文字)次へを非活性に
            if nameTxt.count == 0 {
              
                self.nextButton.isEnabled = false
                return
              
            }
            
            // nilでないかつ0文字以上は次へを活性に
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
                    "userName": userNameTextField.text ?? "noname"
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.getCollection()
                    }
                }
            }
        }
    
        //Firestore  コレクションから自分のuserドキュメントのみを取得
        private func getCollection() {
            
    
            db.collection("users").whereField("emailAddress", isEqualTo: emailText2).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
    
                        let data = document.data()
                        let value = data["emailAddress"]
                        print(data)
                        print(value ?? "取得失敗")
                    }
                }
            }
    
        }
    
//    //Firestore  新しいコレクションとドキュメントを作成
//    private func addAdaLovelace() {
//
//        var ref: DocumentReference? = nil
//
//        ref = db.collection("users").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//
//    }
    
//    //Firestore  別のドキュメントをusersコレクションに追加
//    private func addAlanTuring() {
//
//        var ref: DocumentReference? = nil
//
//        ref = db.collection("users").addDocument(data: [
//            "first": "Alan",
//            "middle": "Mathison",
//            "last": "Turing",
//            "born": 1912
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//
//    }
    
    
//    //Firestore  コレクション全体を取得
//    private func getCollection() {
//
//        db.collection("users").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//
//                    let data = document.data()
//                    let value = data["first"]
//                    print(data)
//                    print(value ?? "取得失敗")
//                }
//            }
//        }
//
//    }
    
   
    //タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    //リターンでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
    }

}
