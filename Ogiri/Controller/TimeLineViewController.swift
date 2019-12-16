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
    
    var kaitouArray = [Any]()
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self  //デリゲートメソッドが使えるようになる
        
        //ログインされていることを確認する
        if let user = Auth.auth().currentUser {

        ////↓odaiImageNumber1~4取得↓////
        let storageRefOdaiImage1 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber1").child("\(user.uid).jpeg")

        storageRefOdaiImage1.downloadURL { url, err in

            if url != nil {
                self.XodaiImage1 = url
            }

        }

        let storageRefOdaiImage2 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber2").child("\(user.uid).jpeg")

        storageRefOdaiImage2.downloadURL(completion: { url, err in
            self.XodaiImage2 = url
        })
        
        let storageRefOdaiImage3 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber3").child("\(user.uid).jpeg")

        storageRefOdaiImage3.downloadURL(completion: { url, err in
            self.XodaiImage3 = url
        })

        let storageRefOdaiImage4 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber4").child("\(user.uid).jpeg")

        storageRefOdaiImage4.downloadURL(completion: { url, err in
            self.XodaiImage4 = url
        })
        ////↑odaiImageNumber1~4取得↑////
        
        
        
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
                            self.XcommentNumber2 = (commentTextValue2 as? String)!
                            self.XcommentNumber3 = (commentTextValue3 as? String)!
                            self.XcommentNumber4 = (commentTextValue4 as? String)!
                        }
                    }
                }
        }
        ////↑commentNumber1~4取得↑////
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.timeLineTableView.reloadData()
            
        }

    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    //セクションの中のセルの数(必須)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return kaitouArray.count
//        return 1
//        return 4
        
    }

    //セルをどうやって構築するか(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //識別子がついたセルのサイズを変更する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        //Outlet接続できないため、タグでコンテンツを管理する(このメソッド内でのみ有効)
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let createAtLabel = cell.viewWithTag(3) as! UILabel
        let odaiImageView = cell.viewWithTag(4) as! UIImageView
        let commentTextView = cell.viewWithTag(5) as! UITextView
            
            //(odaiImage/comment)Number1~4をstructに入れる
            if (XodaiImage1 != nil && XodaiImage2 != nil && XodaiImage3 != nil && XodaiImage4 != nil) {
                
                let XXX1 = kaitou1(odaiImage1: XodaiImage1!,commentNumber1: XcommentNumber1)
                let XXX2 = kaitou2(odaiImage2: XodaiImage2!,commentNumber2: XcommentNumber2)
                let XXX3 = kaitou3(odaiImage3: XodaiImage3!,commentNumber3: XcommentNumber3)
                let XXX4 = kaitou4(odaiImage4: XodaiImage4!,commentNumber4: XcommentNumber4)
            
                kaitouArray += [XXX1, XXX2, XXX3, XXX4]
                print("kaitouArray.count:\(kaitouArray.count)")
            
                odaiImageView.sd_setImage(with: XXX1.odaiImage1, completed: {_, _, _, imageUrl in
            
                                print("XXX1.odaiImage1:\(XXX1.odaiImage1)")
                                print("imageUrl:\(imageUrl)")
                                print()
            
                            })
                
                commentTextView.text = XcommentNumber1
                print("XXX1.commentNumber1:\(XXX1.commentNumber1)")
                
            }
            
            
            
            
            
            
            
//            ////profileImageViewとodaiImageViewに表示////
//            let storageref1 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("profileImage").child("\(user.uid).jpeg")
//
//            let storageref2 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber1").child("\(user.uid).jpeg")
//
//            storageref1.downloadURL(completion: { url, err in
//                profileImageView.sd_setImage(with: url, completed: {_, _, _, imageUrl in
//
//                    print("url:\(url)")
//                    print("imageUrl:\(imageUrl)")
//                    print()
//
//                })
//            })
//
//            storageref2.downloadURL(completion: { url, err in
//                odaiImageView.sd_setImage(with: url, completed: {_, _, _, imageUrl in
//
//                    print("url:\(url)")
//                    print("imageUrl:\(imageUrl)")
//                    print()
//
//                })
//            })
            
            
            
//            ////userNameLabelとcommentTextViewXXXとcreatedAt////
//            db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
//                        if let err = err {
//                            print("Error getting documents: \(err)")
//                        } else {
//                            for document in querySnapshot!.documents {
//                                print("\(document.documentID) => \(document.data())")
//
//                                let data = document.data()
//                                let userNameValue = data["userName"]
//                                let commentTextValue = data["commentNumber1"]
//                                let createdAtValue = data["createdAt"]
//                                print(data)
//                                print(userNameValue ?? "取得失敗")
//                                print(commentTextValue ?? "取得失敗")
//                                print(createdAtValue ?? "取得失敗")
//
//                                userNameLabel.text = userNameValue as? String
//                                commentTextView.text = commentTextValue as? String
//                                createAtLabel.text = createdAtValue as? String
//
//                            }
//                        }
//                    }
//
//        }
        

        return cell
        
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return view.frame.size.height/2
        
    }

}
