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
    
    var XodaiImage1:URL? = nil  //firebaseからDLした画像urlを代入する変数↓
    var XodaiImage2:URL? = nil  //
    var XodaiImage3:URL? = nil  //
    var XodaiImage4:URL? = nil  //
    var XcommentNumber1:String = ""  //firebaseからDLしたコメントを代入する変数↓
    var XcommentNumber2:String = ""  //
    var XcommentNumber3:String = ""  //
    var XcommentNumber4:String = ""  //
    var storagerefProfileImage:StorageReference? = nil  //プロフィール画像を取得するための変数
    var userNameValue:Any?  //ユーザーネームを取得するための変数
    var createdAtValue:Any? //投稿時間を取得するための変数
    
//    var kaitouArray = [Any]()
    var kaitouArray: [Kaitou?] = [nil, nil, nil, nil]
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self  //デリゲートメソッドが使えるようになる
        
        //ログインされていることを確認する
        if let user = Auth.auth().currentUser {
            
            //profileImageの取得
            storagerefProfileImage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("profileImage").child("\(user.uid).jpeg")
            
            
            //userNameとcreateAtの取得
            db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")

                        let data = document.data()
                        self.userNameValue = data["userName"]
                        self.createdAtValue = data["createdAt"]
                        print(data)
                        print(self.userNameValue ?? "取得失敗")
                        print(self.createdAtValue ?? "取得失敗")
                    }
                }
            }
            

        ////↓odaiImageNumber1~4取得↓////
        let storageRefOdaiImage1 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber1").child("\(user.uid).jpeg")

        storageRefOdaiImage1.downloadURL { url, err in

            if url != nil {
                self.XodaiImage1 = url
                if url != nil && !self.XcommentNumber1.isEmpty {
                    // 構造体を所定の場所に保存
                    self.kaitouArray[0] = Kaitou(odaiImage: url!,commentNumber: self.XcommentNumber1)
                    // データが埋まったので再描画をリクエスト
                    self.timeLineTableView.reloadData()
                }
            }
        }

        let storageRefOdaiImage2 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber2").child("\(user.uid).jpeg")

        storageRefOdaiImage2.downloadURL { url, err in
            
            if url != nil {
                self.XodaiImage2 = url
                if url != nil && !self.XcommentNumber2.isEmpty {
                    // 構造体を所定の場所に保存
                    self.kaitouArray[1] = Kaitou(odaiImage: url!,commentNumber: self.XcommentNumber2)
                    // データが埋まったので再描画をリクエスト
                    self.timeLineTableView.reloadData()
                }
            }
        }
        
        let storageRefOdaiImage3 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber3").child("\(user.uid).jpeg")

        storageRefOdaiImage3.downloadURL { url, err in
            
            self.XodaiImage3 = url
            if url != nil && !self.XcommentNumber3.isEmpty {
                // 構造体を所定の場所に保存
                self.kaitouArray[2] = Kaitou(odaiImage: url!,commentNumber: self.XcommentNumber3)
                // データが埋まったので再描画をリクエスト
                self.timeLineTableView.reloadData()
            }
        }

        let storageRefOdaiImage4 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber4").child("\(user.uid).jpeg")

        storageRefOdaiImage4.downloadURL { url, err in
            
            self.XodaiImage4 = url
            if url != nil && !self.XcommentNumber4.isEmpty {
                // 構造体を所定の場所に保存
                self.kaitouArray[3] = Kaitou(odaiImage: url!,commentNumber: self.XcommentNumber3)
                // データが埋まったので再描画をリクエスト
                self.timeLineTableView.reloadData()
            }
        }////↑odaiImageNumber1~4取得↑////
        
        
        
        ////↓commentNumber1~4取得↓////
        db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let commentTextValue1 = data["commentNumber1"]
                            let commentTextValue2 = data["commentNumber2"]
                            let commentTextValue3 = data["commentNumber3"]
                            let commentTextValue4 = data["commentNumber4"]
                            
                            self.XcommentNumber1 = (commentTextValue1 as? String)!
                            if self.XodaiImage1 != nil && !self.XcommentNumber1.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[0] = Kaitou(odaiImage: self.XodaiImage1!,commentNumber: self.XcommentNumber1)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }
                            
                            self.XcommentNumber2 = (commentTextValue2 as? String)!
                            if self.XodaiImage2 != nil && !self.XcommentNumber2.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[1] = Kaitou(odaiImage: self.XodaiImage2!,commentNumber: self.XcommentNumber2)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }
                            
                            self.XcommentNumber3 = (commentTextValue3 as? String)!
                            if self.XodaiImage3 != nil && !self.XcommentNumber3.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[2] = Kaitou(odaiImage: self.XodaiImage3!,commentNumber: self.XcommentNumber3)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }
                            
                            self.XcommentNumber4 = (commentTextValue4 as? String)!
                            if self.XodaiImage4 != nil && !self.XcommentNumber4.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[3] = Kaitou(odaiImage: self.XodaiImage4!,commentNumber: self.XcommentNumber4)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }
                        }
                    }
                }////↑commentNumber1~4取得↑////
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
        return kaitouArray.count
    }

    //セルをどうやって構築するか(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //識別子がついたセルのサイズを変更する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        //配列が空の時
        if kaitouArray[indexPath.row] == nil {
            // データが存在していないので、セルに何もせずそのまま返却して終了。
            return cell
        }
        
        //Outlet接続できないため、タグでコンテンツを管理する(このメソッド内でのみ有効)
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let createAtLabel = cell.viewWithTag(3) as! UILabel
        let odaiImageView = cell.viewWithTag(4) as! UIImageView
        let commentTextView = cell.viewWithTag(5) as! UITextView
            
        //odaiImageViewへの表示
        odaiImageView.sd_setImage(with: kaitouArray[indexPath.row]?.odaiImage, completed: {_, _, _, imageUrl in

            print("odaiImage:\(self.kaitouArray[indexPath.row]?.odaiImage)")
                                print("imageUrl:\(imageUrl)")
                            })
        
        //commentTextViewへの表示
        commentTextView.text = kaitouArray[indexPath.row]?.commentNumber
        print("commentNumber:\(kaitouArray[indexPath.row]?.commentNumber)")
            
        //profileImageViewへの表示
        storagerefProfileImage?.downloadURL(completion: { url, err in
            if url != nil {
                profileImageView.sd_setImage(with: url, completed: {_, _, _, imageUrl in

                    print("profileurl:\(url)")
                    print("imageUrl:\(imageUrl)")
                })
            }else{
                profileImageView.image = UIImage(named: "Default")
            }
            })
            
        //userNameLabelとcreateAtLabelへの表示
        userNameLabel.text = userNameValue as? String
        createAtLabel.text = createdAtValue as? String
            
        return cell
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/2
    }
}
