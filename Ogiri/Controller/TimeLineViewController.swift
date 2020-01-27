//
//  TimeLineViewController.swift
//  Ogiri
//
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class TimeLineViewController:
      UIViewController,
      UITableViewDelegate,
      UITableViewDataSource {
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    let db = Firestore.firestore()
    var storagerefProfileImage:StorageReference? = nil  //storageからDLしたプロフィール画像を取得するための変数
    var kaitouArray2: [Kaitou?] = []  //ユーザーの4題の回答のデータをまとめ、のちにkaitouArrayに入れる
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self  //デリゲートメソッドが使えるようになる

        
        
        ///////////////////ログインされていることを確認する
        if let user = Auth.auth().currentUser {
//
//            if user.isAnonymous == true {
//                print("匿名ユーザー")
//            }else{
//                print("登録ユーザー")
//            }



            //userNameとpostedAtとuidとcomment1~4を取得し、配列kaitouArray2に格納
            db.collection("users").order(by: "postedAt",descending: true).limit(to: 25).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")

                        let data = document.data()
                        self.kaitouArray2.append(Kaitou(comment: data["comment1"] as! String,
                                                        uid: data["uid"] as! String,
                                                        userName: data["userName"] as! String,
                                                        postedAt: data["postedAt"] as! String,
                                                        folder: 1))
                        
                        self.kaitouArray2.append(Kaitou(comment: data["comment2"] as! String,
                                                        uid: data["uid"] as! String,
                                                        userName: data["userName"] as! String,
                                                        postedAt: data["postedAt"] as! String,
                                                        folder: 2))
                        
                        self.kaitouArray2.append(Kaitou(comment: data["comment3"] as! String,
                                                        uid: data["uid"] as! String,
                                                        userName: data["userName"] as! String,
                                                        postedAt: data["postedAt"] as! String,
                                                        folder: 3))
                        
                        self.kaitouArray2.append(Kaitou(comment: data["comment4"] as! String,
                                                        uid: data["uid"] as! String,
                                                        userName: data["userName"] as! String,
                                                        postedAt: data["postedAt"] as! String,
                                                        folder: 4))
                        print("data:\(data)")
                        print("kaitouArray2:\(self.kaitouArray2)")
                    }
                    self.timeLineTableView.reloadData()
                }
            }
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        }
    
    

    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    //セクションの中のセルの数(必須)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kaitouArray2.count
    }

    //セルをどうやって構築するか(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //識別子がついたセルのサイズを変更する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        //配列が空の時
        if kaitouArray2[indexPath.row] == nil {
            // データが存在していないので、セルに何もせずそのまま返却して終了。
            return cell
        }
        
        //Outlet接続できないため、タグでコンテンツを管理する(このメソッド内でのみ有効)
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let postedAtLabel = cell.viewWithTag(3) as! UILabel
        let odaiImageView = cell.viewWithTag(4) as! UIImageView
        let commentTextView = cell.viewWithTag(5) as! UITextView
        
        
        ////↓odaiImageNumber1~4取得↓////
        let storageRefOdaiImage1 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber1")
            storageRefOdaiImage1.listAll(completion: { (StorageListResult, error) in
                if let error = error {
                    print(".listAllのエラー:\(error)")
                    } else {
                    for ref in StorageListResult.items {
                            print("1題目の画像:\(ref)")
                        }
                    }
            })//全ユーザーの1題目の画像(odaiImageNumber1)は取得できてる

        

        let storageRefOdaiImage2 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber2")
            storageRefOdaiImage2.listAll(completion: { (StorageListResult, error) in
                if let error = error {
                    print(".listAllのエラー:\(error)")
                    } else {
                    for ref in StorageListResult.items {
                            print("2題目の画像:\(ref)")
                        }
                    }
            })//全ユーザーの2題目の画像(odaiImageNumber1)は取得できてる
            
            
            

//        let storageRefOdaiImage3 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/odaiImageNumber3/\(kaitouArray2[indexPath.row]!.uid).jpeg")
//        storageRefOdaiImage3.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            odaiImageView.image = UIImage(data: data!)!
//        }
            
            
            
            
        let storageRefOdaiImage4 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/odaiImageNumber\(kaitouArray2[indexPath.row]!.folder)/\(kaitouArray2[indexPath.row]!.uid).jpeg")
        storageRefOdaiImage4.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if data == nil {
                print("dataがnilです")
            }else {
                odaiImageView.image = UIImage(data: data!)!
            }
        }
        
                
        
        //commentTextViewへの表示
        commentTextView.text = kaitouArray2[indexPath.row]?.comment
        print("comment:\(kaitouArray2[indexPath.row]?.comment)")
            
        //profileImageViewへの表示
        let storageRefProfileImage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/profileImage/\(kaitouArray2[indexPath.row]!.uid).jpeg")
        storageRefProfileImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if data != nil {
                profileImageView.image = UIImage(data: data!)!
            }else{
                profileImageView.image = UIImage(named: "Default")
            }
        }
        
                    
        //userNameLabelとpostedAtLabelへの表示
        userNameLabel.text = self.kaitouArray2[indexPath.row]?.userName
        postedAtLabel.text = self.kaitouArray2[indexPath.row]?.postedAt
        print("postedAtLabel:\(postedAtLabel.text)")
            
        return cell
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/2
    }
}
