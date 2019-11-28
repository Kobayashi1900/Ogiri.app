//
//  TimeLineViewController.swift
//  Ogiri
//
//

import UIKit
import Firebase
import FirebaseAuth

class TimeLineViewController:
      UIViewController,
      UITableViewDelegate,
      UITableViewDataSource {
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    let db = Firestore.firestore()
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self  //デリゲートメソッドが使えるようになる

    }
    
    override func viewWillAppear(_ animated: Bool) {
            
        }

    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }


    //セクションの中のセルの数(必須)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1

    }

    //セルをどうやって構築するか(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //識別子がついたセルのサイズを変更する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Outlet接続できないため、タグでコンテンツを管理する(このメソッド内でのみ有効)
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        
        let odaiImageView = cell.viewWithTag(3) as! UIImageView
        
        let commentTextView = cell.viewWithTag(4) as! UITextView
        
        /////////////各UI部品に反映する///////////////
        //ログインされていることを確認する
        if let user = Auth.auth().currentUser {
        
            ////profileImageViewに表示////
            let storageref1 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("profileImage").child("\(user.uid).jpeg")

            profileImageView.sd_setImage(with: storageref1)
            print("storageref1:\(storageref1)")
            
            ////userNameLabelとcommentTextView////
            db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
            
                                let data = document.data()
                                let userNameValue = data["userName"]
                                let commentTextValue = data["commentNumber1"]
                                print(data)
                                print(userNameValue ?? "取得失敗")
                                print(commentTextValue ?? "取得失敗")
                                userNameLabel.text = userNameValue as? String
                                commentTextView.text = commentTextValue as? String
                            }
                        }
                    }
            
            ////odaiImageView////
            let storageref2 = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com").child("odaiImageNumber1").child("\(user.uid).jpeg")

            odaiImageView.sd_setImage(with: storageref2)
            print("storageref2:\(storageref2)")
         }
        
        
        

        return cell
        
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return view.frame.size.height/2
        
    }


}
