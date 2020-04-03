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
    
    let db = Firestore.firestore()   //firestoreに保存した値を取得するため
    var kaitouArray: [Kaitou?] = []  //ユーザーの4題の回答のデータをまとめるため
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self  //デリゲートメソッドが使えるようになる
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        display()  //タイムラインに各ユーザーの大喜利を表示
        print("保存された値：\(UserDefaults.standard.object(forKey: "blocked"))")
    }
    
    
    @IBAction func blockButton(_ sender: BlockButton) {
        
        //キー値blockedで保存された値がない(ブロックしたことが無い)場合、
        if UserDefaults.standard.object(forKey: "blocked") == nil {
            let XXX = ["XX" : true]
            UserDefaults.standard.set(XXX, forKey: "blocked")  //UserDefaultsのキー値blockedにとりあえず初期値を入れておく
        }
        
        //現時点で、キー値blockedで保存されている値をblockDicに追加する
        var blockDic:[String:Bool] = UserDefaults.standard.object(forKey: "blocked") as! [String : Bool]
        blockDic["\(sender.uid)" + "\(sender.folder)"] = true  //辞書blockDicにkey[uid+folder],value-trueでデータを追加
        UserDefaults.standard.set(blockDic, forKey: "blocked") //UserDefaultsのキー値blockedの値として、辞書blockDicを保存
        
        display()  //再描画
    }
    
    
    @IBAction func reportButton(_ sender: Any) {
        
        let url = URL(string: "http://hari-blog.com/report")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
        let blockButton = cell.viewWithTag(6) as! BlockButton
        
        //各ブロックボタンにはプロパティとしてuid,folderがある。indexPath.row番目に対応するuid,folderを代入している
        blockButton.uid = kaitouArray[indexPath.row]!.uid
        blockButton.folder = kaitouArray[indexPath.row]!.folder

        
        //profileImageViewへの表示
        let storageRefProfileImage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/profileImage/\(kaitouArray[indexPath.row]!.uid).jpeg")
        storageRefProfileImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if data != nil {
                profileImageView.image = UIImage(data: data!)!
            }else{
                profileImageView.image = UIImage(named: "Default")
            }
        }
        
        //userNameLabelとpostedAtLabelへの表示
        userNameLabel.text = kaitouArray[indexPath.row]?.userName
        postedAtLabel.text = kaitouArray[indexPath.row]?.postedAt
        
        //お題の画像の取得とodaiImageViewへの表示
        let storageRefOdaiImage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/odaiImageNumber\(kaitouArray[indexPath.row]!.folder)/\(kaitouArray[indexPath.row]!.uid).jpeg")
        storageRefOdaiImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if data == nil {
                print(error!.localizedDescription)
            }else{
                odaiImageView.image = UIImage(data: data!)!
            }
        }
        
        //commentTextViewへの表示
        commentTextView.text = kaitouArray[indexPath.row]?.comment
            
        return cell
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/2
    }
    
    
    func display() {
        
        //誰もブロックしていない(キー値blockedで保存された値が無い)場合
        if UserDefaults.standard.object(forKey: "blocked") == nil {
            let XXX = ["XX" : true]
            UserDefaults.standard.set(XXX, forKey: "blocked")  //とりあえず初期値を入れておく
        }
        
        //事前にUserDefaultsの中身を取得
        let blockList:[String:Bool] = UserDefaults.standard.object(forKey: "blocked") as! [String:Bool]
        
          //ログインされていることを確認する
          if let user = Auth.auth().currentUser {
                          
              if user.isAnonymous == true {  //カレントユーザーが匿名ユーザーなら
                                  
                  //コレクションusersから全ての匿名ユーザーのドキュメントを取得し、各フィールドを配列kaitouArrayに格納
                  db.collection("users").whereField("userName", isEqualTo: "匿名ユーザー").limit(to: 10).getDocuments() { (querySnapshot, err) in
                      if let err = err {
                          print("Error getting documents: \(err)")
                      } else {
                            self.kaitouArray.removeAll()  //画面遷移時にTLが更新されるように、removeAllしてからまたkaitouArrayにappendする
                        
                                for document in querySnapshot!.documents {

                                    let data = document.data()
                            
                                        if data["comment1"] != nil {
                                            
                                            //data["uid"]をアンラップ　→　オプショナル型のため
                                            if let data_uid = data["uid"] {
                                                
                                                //key["\(data_uid)1"]で保存された値があり、その値がtrueなら、kaitouArrayに加えない = 何もしない
                                                if let blockFlag = blockList["\(data_uid)1"], blockFlag == true {
                                            
                                                }else{//そうでなければ(ブロックしていなければ)、kaitouArrayに加える。(表示する)
                                                    self.kaitouArray.append(Kaitou(comment: data["comment1"] as! String,
                                                                                            uid: data["uid"] as! String,
                                                                                            userName: data["userName"] as! String,
                                                                                            postedAt: data["postedAt"] as! String,
                                                                                            folder: 1))
                                                }
                                            }
                                        }
                                    
                                  
                                        if data["comment2"] != nil {
                                            if let data_uid = data["uid"] {
                                                if let blockFlag = blockList["\(data_uid)2"], blockFlag == true {
                                            
                                                }else{
                                                    self.kaitouArray.append(Kaitou(comment: data["comment2"] as! String,
                                                                                            uid: data["uid"] as! String,
                                                                                            userName: data["userName"] as! String,
                                                                                            postedAt: data["postedAt"] as! String,
                                                                                            folder: 2))
                                                }
                                            }
                                        }
                                    
                                    
                                        if data["comment3"] != nil {
                                            if let data_uid = data["uid"] {
                                                if let blockFlag = blockList["\(data_uid)3"], blockFlag == true {
                                            
                                                }else{
                                                    self.kaitouArray.append(Kaitou(comment: data["comment3"] as! String,
                                                                                            uid: data["uid"] as! String,
                                                                                            userName: data["userName"] as! String,
                                                                                            postedAt: data["postedAt"] as! String,
                                                                                            folder: 3))
                                                }
                                            }
                                        }
                                    
                                  
                                        if data["comment4"] != nil {
                                            if let data_uid = data["uid"] {
                                                if let blockFlag = blockList["\(data_uid)4"], blockFlag == true {
                                            
                                                }else{
                                                    self.kaitouArray.append(Kaitou(comment: data["comment4"] as! String,
                                                                                            uid: data["uid"] as! String,
                                                                                            userName: data["userName"] as! String,
                                                                                            postedAt: data["postedAt"] as! String,
                                                                                            folder: 4))
                                                }
                                            }
                                        }
                                        print("data:\(data)")
                                        print("kaitouArray(匿名者用):\(self.kaitouArray)")
                                }
                          self.timeLineTableView.reloadData()
                      }
                  }
                  }else{//カレントユーザーが登録ユーザーなら
                  
                      //コレクションusers全体を取得し、userNameとpostedAtとuidとcomment1~4を配列kaitouArrayに格納
                      db.collection("users").order(by: "postedAt",descending: true).limit(to: 25).getDocuments() { (querySnapshot, err) in
                          if let err = err {
                              print("Error getting documents: \(err)")
                          } else {
                            self.kaitouArray.removeAll()  //画面遷移時にTLが更新されるように、removeAllしてからまたkaitouArrayにappendする
                            
                              for document in querySnapshot!.documents {

                                  let data = document.data()

                                    if data["comment1"] != nil {
                                        if let data_uid = data["uid"] {
                                            if let blockFlag = blockList["\(data_uid)1"], blockFlag == true {
                                            
                                            }else{
                                                self.kaitouArray.append(Kaitou(comment: data["comment1"] as! String,
                                                                                        uid: data["uid"] as! String,
                                                                                        userName: data["userName"] as! String,
                                                                                        postedAt: data["postedAt"] as! String,
                                                                                        folder: 1))
                                            }
                                        }
                                    }
                                
                                
                                    if data["comment2"] != nil {
                                        if let data_uid = data["uid"] {
                                            if let blockFlag = blockList["\(data_uid)2"], blockFlag == true {
                                            
                                            }else{
                                                self.kaitouArray.append(Kaitou(comment: data["comment2"] as! String,
                                                                                        uid: data["uid"] as! String,
                                                                                        userName: data["userName"] as! String,
                                                                                        postedAt: data["postedAt"] as! String,
                                                                                        folder: 2))
                                            }
                                        }
                                    }
                                  
                                
                                    if data["comment3"] != nil {
                                        if let data_uid = data["uid"] {
                                            if let blockFlag = blockList["\(data_uid)3"], blockFlag == true {
                                            
                                            }else{
                                                self.kaitouArray.append(Kaitou(comment: data["comment3"] as! String,
                                                                                        uid: data["uid"] as! String,
                                                                                        userName: data["userName"] as! String,
                                                                                        postedAt: data["postedAt"] as! String,
                                                                                        folder: 3))
                                            }
                                        }
                                    }
                                  
                                
                                    if data["comment4"] != nil {
                                        if let data_uid = data["uid"] {
                                            if let blockFlag = blockList["\(data_uid)4"], blockFlag == true {
                                            
                                            }else{
                                                self.kaitouArray.append(Kaitou(comment: data["comment4"] as! String,
                                                                                        uid: data["uid"] as! String,
                                                                                        userName: data["userName"] as! String,
                                                                                        postedAt: data["postedAt"] as! String,
                                                                                        folder: 4))
                                            }
                                        }
                                    }
                                
                                  print("data:\(data)")
                                  print("kaitouArray(登録者用):\(self.kaitouArray)")
                              }
                              self.timeLineTableView.reloadData()
                          }
                      }
                  }
        }
    }
}
