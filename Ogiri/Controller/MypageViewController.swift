//
//  MypageViewController.swift
//  Ogiri
//
//  Created by kobayashi on 2019/10/08.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class MypageViewController:
      UIViewController,
      UIImagePickerControllerDelegate,
      UINavigationControllerDelegate,
      UITextFieldDelegate{
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var imageSettingButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var announcement: UILabel!
    
    let db = Firestore.firestore()  //ドキュメントに新しいユーザーネームを保存するため
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        getCollection()
        validate()
    }
        
    
    @IBAction func imageSetting(_ sender: Any) {
        
        showAlert()  //アルバムから画像を選択させるアラートメソッド
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        // ログインされていること確認する
        guard let user = Auth.auth().currentUser else { return }
        
        //ストレージサーバのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/")
        
        //画像URLが「uid.jpeg」となるように保存
        let imageRef = storage.child("profileImage").child("\(user.uid).jpeg")
        
        //ProfileImageのデータを変数として持つ
        var ProfileImageData: Data = Data()
        
        //プロフィール画像が存在すれば
        if profileImageView.image != nil {
            
        //画像を圧縮
        ProfileImageData = (profileImageView.image?.jpegData(compressionQuality: 0.01))!
        }
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        //アップロードタスク(storageに画像を送信)
        imageRef.putData(ProfileImageData, metadata: meta) { (metaData, error) in
        
            //エラーであれば
            if error != nil {
                print(error.debugDescription)
                return  //これより下にはいかないreturn
            }
        }
        
        updateProfile()  //ドキュメントのフィールド更新メソッド
    }
    
    //タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //リターンでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
    }
    
    //アルバム立ち上げメソッド
    func album() {
        
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        //アルバム利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let cameraPicker = UIImagePickerController()//インスタンス生成
            cameraPicker.allowsEditing = true          //画像の編集→可能
            cameraPicker.sourceType = sourceType       //ソースはlet sourceType(.photoLibrary)
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //アルバムから選択された画像のデータが入ってくるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if info[.originalImage] as? UIImage != nil{  //画像があれば

            //定数selectedImageに画像データを入れる
            let selectedImage = info[.originalImage] as! UIImage

            //profileImageViewに反映させる
            profileImageView.image = selectedImage

            picker.dismiss(animated: true, completion: nil)//ピッカー閉じる
        }
    }
    
    //アルバムから画像を選択させるアラートを出すメソッド
    func showAlert() {
        
        let alertController = UIAlertController(title: "", message: "画像を選択してください", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            
        self.album()  //アルバムを表示するメソッド
        }
        
        let action2 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        //アラートを表示させる
        self.present(alertController, animated: true, completion: nil)
    }
    
    //ドキュメントのフィールドを更新
    private func updateProfile() {
        
        //別のVCでドキュメント名を.uidで作成しているので、userIdに.uidを代入
        guard let userId = Auth.auth().currentUser?.uid else { fatalError() }
        
        //ドキュメントのパスをrefに代入
        let ref = db.collection("users").document(userId)
        
        ref.updateData([
            "userName": userNameTextField.text ?? "noname"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    //自分のドキュメントを取得し、最新のユーザーネームをuserNameTextFieldに表示&プロフィール画像の表示
    private func getCollection() {
        
        //別のVCでドキュメント名を.uidで作成しているので、userIDに.uidを代入
        guard let userID = Auth.auth().currentUser?.uid else { fatalError() }
        
        //自分のユーザー情報を取得(ドキュメントusersでkey(uid)のvalueがuserIDと一致するものを取得)して、key(userName)に新名入れる
        db.collection("users").whereField("uid", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
        
                            let data = document.data()
                            let value = data["userName"]
                            self.userNameTextField.text = value as? String
                            print(data)
                            print(value ?? "取得失敗")
                        }
                    }
                }
        
        //profileImageViewに登録した画像があれば、storageから取得しそれを表示
        //StorageのURLを参照
        let storageref = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("profileImage").child("\(userID).jpeg")
                
            storageref.downloadURL(completion: { url, error in
                
                if url != nil {
                    self.profileImageView.sd_setImage(with: url, completed: nil)
                }else{  //登録がなければデフォ画像を表示
                    self.profileImageView.image = UIImage(named: "Default")
                }
            })
    }
    
    private func validate() {  //ボタンとTextFieldの非活性
        // ログインされていること確認する
        guard let user = Auth.auth().currentUser else { return }

            if user.isAnonymous == true {  //カレントユーザーが匿名ユーザーなら
                self.imageSettingButton.isEnabled = false
                self.saveButton.isEnabled = false
                self.userNameTextField.isEnabled = false
            }else {
                self.announcement.isHidden = true
        }
    }
}
