//
//  SignUpViewController.swift
//  Ogiri
//
//  Created by kobayashi on 2019/08/26.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class SignUpViewController:
      UIViewController,
      UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    let db = Firestore.firestore()//匿名ユーザーのドキュメントを追加するため(匿名ユーザーをTLで取得するため)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    @IBAction func emailEditChanged(_ sender: UITextField) {
        
        self.validate()
    }
    
    
    @IBAction func passwordEditChanged(_ sender: UITextField) {
        
        self.validate()
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        //メアドとパスでアカウント作成
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                self.defaultOdaiImageAdd()  //コンパイルエラーを防ぐために、とりあえずお題の画像にデフォルトのものを保存しておく
            }
            
            //navigationControllerで画面遷移
            let UserNameVC = self.storyboard?.instantiateViewController(withIdentifier: "unvc")  as! UserNameViewController
            
            //値渡し  UserNameViewControllerでdbにまとめて保存するため。
            UserNameVC.emailText2 = self.emailTextField.text
            self.navigationController?.pushViewController(UserNameVC, animated: true)
        }
    }
    
    
    
    @IBAction func play(_ sender: Any) {
        
        //匿名ログイン
        Auth.auth().signInAnonymously() { (authResult, error) in
            
            var ref: DocumentReference? = nil

            // ログインされていること確認する
            guard let userID = Auth.auth().currentUser?.uid else { fatalError() }

            ref = self.db.collection("users").document(userID)

                //TLで匿名ユーザーのみを取得するために「"userName": 匿名ユーザー」というフィールドを追加
                //コンパイルエラーしないよう、仮の値を各フィールドに追加
                ref?.setData([
                    "uid": userID,
                    "userName": "匿名ユーザー",
                    "postedAt": "投稿されていません",
                    "comment1": "まだコメントはありません",
                    "comment2": "まだコメントはありません",
                    "comment3": "まだコメントはありません",
                    "comment4": "まだコメントはありません"
                ], merge: true) { error in
                    if let error = error {
                        print("Error setData document: \(error)")
                    } else {
                        print("Document successfully setData")
                    }
                }
            self.defaultOdaiImageAdd()
        }
        
        //PlayViewControllerに遷移させる
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID")  as! UITabBarController
        tabbarController.selectedIndex = 1
        self.navigationController?.pushViewController(tabbarController, animated: true)
    }
    
    
    @IBAction func login(_ sender: Any) {
        
        //navigationControllerでLoginViewControllerへ画面遷移
        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginvc")  as! LoginViewController
        self.navigationController?.pushViewController(LoginVC, animated: true)
    }
    
    func validate() {
        
            // nilの場合はnextButtonを非活性に
            guard let emailTxt = emailTextField.text,
                  let passTxt = passwordTextField.text else {
                    
                    self.nextButton.isEnabled = false
                      return
            }
        
            //アドレスが正規かつパスワードが6文字以上の場合nextButtonを活性に
            if validateEmail(candidate: emailTxt) && passTxt.count >= 6 {
                self.nextButton.isEnabled = true
                return
            }else{
                self.nextButton.isEnabled = false
        }
                    
            
    }
    
    func validateEmail(candidate: String) -> Bool {
     let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    //タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    //リターンでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
    }
    
    
    func defaultOdaiImageAdd() {
        // ログインされていること確認する
        guard let user = Auth.auth().currentUser else { return }
        
        //ストレージサーバのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/")
        
        // パス  /  画像のURLが「uid.jpeg」となるように保存
        let imageRef1 = storage.child("odaiImageNumber1").child("\(user.uid).jpeg")
        let imageRef2 = storage.child("odaiImageNumber2").child("\(user.uid).jpeg")
        let imageRef3 = storage.child("odaiImageNumber3").child("\(user.uid).jpeg")
        let imageRef4 = storage.child("odaiImageNumber4").child("\(user.uid).jpeg")
        
        //保存したい画像のデータを変数として持つ
        var odaiImageData: Data = Data()
        
        odaiImageData = (UIImage(named: "image8")!.jpegData(compressionQuality: 0.01))!
        
        //storageに画像を送信
        imageRef1.putData(odaiImageData, metadata: nil)
        imageRef2.putData(odaiImageData, metadata: nil)
        imageRef3.putData(odaiImageData, metadata: nil)
        imageRef4.putData(odaiImageData, metadata: nil)
    }
}
