//
//  MypageViewController.swift
//  Ogiri
//
//  Created by kobayashi riku on 2019/10/08.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Firebase


class MypageViewController:
      UIViewController,
      UIImagePickerControllerDelegate,
      UINavigationControllerDelegate,
      UITextFieldDelegate{
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self

    }
    
    
    @IBAction func imageSetting(_ sender: Any) {
        
        //アルバムから選択させるアラートメソッドを呼ぶ
        showAlert()
        
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        //DBの行き先(child)を決めていく
        let myPageDB = Database.database().reference().child("myPage").childByAutoId()
        
        //ストレージサーバのURLを取得
        let storage = Storage.storage().reference(forURL: "")
        
        //画像が入るフォルダを作る(""内がフォルダ名)
        let key = myPageDB.child("ProfileImage").childByAutoId().key
        
        let imageRef = storage.child("profileImage").child("\(String(describing: key!)).jpeg")
        
        //ProfileImageのデータを変数として持つ
        var ProfileImageData: Data = Data()
        
        //プロフィール画像が存在すれば
        if profileImageView.image != nil {
            
            //画像を圧縮
            ProfileImageData = (profileImageView.image?.jpegData(compressionQuality: 0.01))!
            
        }
        
        //アップロードタスク(storageに画像を送信)
        let uploadTask = imageRef.putData(ProfileImageData, metadata: nil) { (metaData, error) in
            
            //エラーであれば
            if error != nil {
                
                print(error)
                return  //これより下にはいかないreturn
                
            }
            
            //storageから画像が保存されているURLをダウンロードする
            imageRef.downloadURL { (url, error) in
                
                //urlが存在すれば
                if url != nil {
                    
                    //キーバリュー(辞書)型でDBへ送信するものを準備する
                    //各キー値を元に受信していく (クロージャ内だから要self)
//                    let timeLineInfo =
                    
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
    
    //アルバム立ち上げメソッド
    func album() {
        
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        //アルバム利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let cameraPicker = UIImagePickerController()//インスタンス生成
            cameraPicker.allowsEditing = true  //画像の編集→可能
            cameraPicker.sourceType = sourceType //ソースはlet sourceType(.photoLibrary)
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        
    }
    
    //選択された画像のデータが入ってくるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] as? UIImage != nil{
            
            //let selectedImageに画像データを入れる
            let selectedImage = info[.originalImage] as! UIImage
            
            //選択された画像を圧縮してアプリ内に保存
            //UserDefaults.standard.set(selectedImage.jpegData(compressionQuality: 0.1), forKey: "userImage")
            
            //profileImageViewに反映させる
            profileImageView.image = selectedImage
            
            picker.dismiss(animated: true, completion: nil)//ピッカー閉じる
            
        }
        
    }
    
    //キャンセルが押された時にピッカーを閉じる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    
    }
    
    //アルバムから画像を選択させるアラートを出すメソッド
    func showAlert() {
        
        let alertController = UIAlertController(title: "", message: "画像を選択してください", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
        
        self.album()
        
        }
        
        let action2 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        //アラートを表示させる
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
}
