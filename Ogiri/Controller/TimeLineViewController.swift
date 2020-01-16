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
    
    var XodaiImage1:URL? = nil  //storageからDLした画像urlを代入する変数
    var XodaiImage2:URL? = nil  //
    var XodaiImage3:URL? = nil  //
    var XodaiImage4:URL? = nil  //
    var Xcomment1:String = ""  //firebaseからDLしたコメントを代入する変数
    var Xcomment2:String = ""  //
    var Xcomment3:String = ""  //
    var Xcomment4:String = ""  //
    var storagerefProfileImage:StorageReference? = nil  //storageからDLしたプロフィール画像を取得するための変数
    var userNameValue:Any?  //firebaseからDLしたユーザーネームを取得するための変数
    var postedAt:Any? //firebaseからDLした投稿時間を取得するための変数
    var Xuid:Any?  //firebaseからDLしたuidを取得するための変数
    
    var kaitouArray: [Kaitou?] = [nil, nil, nil, nil]
    
    
   
    
    
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

            //profileImageの取得
            storagerefProfileImage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("profileImage")
            
            storagerefProfileImage?.listAll(completion: { (StorageListResult, error) in
                if let error = error {
                    print(".listAllのエラー:\(error)")
                } else {
                    for ref in StorageListResult.items {
                        print("プロフ画:\(ref)")
                    }
                }
            })//全ユーザーのprofileImageは取得できてる


            //userNameとpostedAtとuidの取得
            db.collection("users").order(by: "postedAt",descending: true).limit(to: 100).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")

                        let data = document.data()
                        self.userNameValue = data["userName"]
                        self.postedAt = data["postedAt"]
                        self.Xuid = data["uid"]
                        print("data:\(data)")
                        print("userNameValue:\(self.userNameValue ?? "取得失敗")" )
                        print("postedAt:\(self.postedAt ?? "取得失敗")" )
                        print("Xuid:\(self.Xuid ?? "取得失敗")" )
                    }
                }
            }//全ユーザーのuserNameとpostedAtは取得できてる


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

        storageRefOdaiImage1.downloadURL { url, err in  //「url」 = 画像のurl つまり「user.uid.jpeg」

            if url != nil {
                self.XodaiImage1 = url
                print("XodaiImage1:\(String(describing: self.XodaiImage1))")
                if url != nil && !self.Xcomment1.isEmpty {
                    // 構造体を所定の場所に保存
                    self.kaitouArray[0] = Kaitou(odaiImage: url!,
                                                 comment: self.Xcomment1,
                                                 uid: self.Xuid as! String)
                    print("kaitouArray[0]:\(self.kaitouArray[0] as Any)")
                    // データが埋まったので再描画をリクエスト
                    self.timeLineTableView.reloadData()
                }
            }
        }

        let storageRefOdaiImage2 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber2")

        storageRefOdaiImage2.downloadURL { url, err in

            if url != nil {
                self.XodaiImage2 = url
                print("XodaiImage2:\(String(describing: self.XodaiImage2))")
                if url != nil && !self.Xcomment2.isEmpty {
                    // 構造体を所定の場所に保存
                    self.kaitouArray[1] = Kaitou(odaiImage: url!,
                                                 comment: self.Xcomment2,
                                                 uid: self.Xuid as! String)
                    // データが埋まったので再描画をリクエスト
                    self.timeLineTableView.reloadData()
                }
            }
        }

        let storageRefOdaiImage3 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber3")

        storageRefOdaiImage3.downloadURL { url, err in

            if url != nil {
                self.XodaiImage3 = url
                print("XodaiImage3:\(String(describing: self.XodaiImage3))")
                if url != nil && !self.Xcomment3.isEmpty {
                    // 構造体を所定の場所に保存
                    self.kaitouArray[2] = Kaitou(odaiImage: url!,
                                                 comment: self.Xcomment3,
                                                 uid: self.Xuid as! String)
                    // データが埋まったので再描画をリクエスト
                    self.timeLineTableView.reloadData()
                }
            }
        }

        let storageRefOdaiImage4 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber4")

        storageRefOdaiImage4.downloadURL { url, err in

            if url != nil {
                self.XodaiImage4 = url
                print("XodaiImage4:\(String(describing: self.XodaiImage4))")
                if url != nil && !self.Xcomment4.isEmpty {
                    // 構造体を所定の場所に保存
                    self.kaitouArray[3] = Kaitou(odaiImage: url!,
                                                 comment: self.Xcomment3,
                                                 uid: self.Xuid as! String)
                    // データが埋まったので再描画をリクエスト
                    self.timeLineTableView.reloadData()
                }
            }
        }////↑odaiImageNumber1~4取得↑////



        ////↓comment1~4取得↓////
        db.collection("users").order(by: "postedAt",descending: true).limit(to: 100).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let commentTextValue1 = data["comment1"]
                            let commentTextValue2 = data["comment2"]
                            let commentTextValue3 = data["comment3"]
                            let commentTextValue4 = data["comment4"]

                            self.Xcomment1 = (commentTextValue1 as? String)!
                            if self.XodaiImage1 != nil && !self.Xcomment1.isEmpty {
                                print("Xcomment1:\(String(describing: self.Xcomment1))")
                                // 構造体を所定の場所に保存
                                self.kaitouArray[0] = Kaitou(odaiImage: self.XodaiImage1!,
                                                             comment: self.Xcomment1,
                                                             uid: self.Xuid as! String)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }
                            

                            self.Xcomment2 = (commentTextValue2 as? String)!
                            if self.XodaiImage2 != nil && !self.Xcomment2.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[1] = Kaitou(odaiImage: self.XodaiImage2!,
                                                             comment: self.Xcomment2,
                                                             uid: self.Xuid as! String)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }

                            self.Xcomment3 = (commentTextValue3 as? String)!
                            if self.XodaiImage3 != nil && !self.Xcomment3.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[2] = Kaitou(odaiImage: self.XodaiImage3!,
                                                             comment: self.Xcomment3,
                                                             uid: self.Xuid as! String)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }

                            self.Xcomment4 = (commentTextValue4 as? String)!
                            if self.XodaiImage4 != nil && !self.Xcomment4.isEmpty {
                                // 構造体を所定の場所に保存
                                self.kaitouArray[3] = Kaitou(odaiImage: self.XodaiImage4!,
                                                             comment: self.Xcomment4,
                                                             uid: self.Xuid as! String)
                                // データが埋まったので再描画をリクエスト
                                self.timeLineTableView.reloadData()
                            }
                        }
                    }
                }////↑comment1~4取得↑////

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
        let postedAtLabel = cell.viewWithTag(3) as! UILabel
        let odaiImageView = cell.viewWithTag(4) as! UIImageView
        let commentTextView = cell.viewWithTag(5) as! UITextView
            
        //odaiImageViewへの表示
        odaiImageView.sd_setImage(with: kaitouArray[indexPath.row]?.odaiImage, completed: {_, _, _, imageUrl in

            print("odaiImage:\(self.kaitouArray[indexPath.row]?.odaiImage)")
                                print("imageUrl:\(imageUrl)")
                            })
        
        //commentTextViewへの表示
        commentTextView.text = kaitouArray[indexPath.row]?.comment
        print("commentNumber:\(kaitouArray[indexPath.row]?.comment)")
            
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
            
        //userNameLabelとpostedAtLabelへの表示
        userNameLabel.text = userNameValue as? String
        postedAtLabel.text = postedAt as? String
            
        return cell
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/2
    }
}
