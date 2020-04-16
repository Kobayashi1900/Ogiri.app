//
//  PlayViewController.swift
//  Ogiri
//
//  Created by kobayashi on 2019/10/07.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Photos
import Firebase
import FirebaseFirestore

class PlayViewController: UIViewController {
    
    @IBOutlet weak var odaiLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    private var tempCommentText: String? = "未回答またはタイムオーバー"      //commentTextView.textを代入する
    private let wordsList = WordsList()       //インスタンス生成、語群にアクセスできる
    var timer = Timer()                       //timerクラスのインスタンス生成
    private var count = 31                    //大喜利の回答制限時間に使う
    private var odaiNumber = 1                //何題目のお題なのか
    var commentNumber = 0                     //それぞれの大喜利の回答をstroageのそれぞれのフォルダに保存するため
    var odaiImageNumber = 0                   //それぞれのお題画像をstroageのそれぞれのフォルダに保存するため
    private var screenShotImagae1 = UIImage() //スクショを入れる変数
    private var screenShotImagae2 = UIImage()
    private var screenShotImagae3 = UIImage()
    private var screenShotImagae4 = UIImage()
    let db = Firestore.firestore()            //ドキュメントにコメントとpostedAtを保存するため
    var ref: DocumentReference? = nil         //ドキュメントにコメントとpostedAtを保存するため
    var isFirstPlay = true                    //匿名ユーザーの最初のplayでtabbarを非表示にするため
    private let baseUrl = "https://pixabay.com/api/"
    private let apiKey = "13787747-8afd4e03ae250892260a92055"
    
    @IBOutlet weak var coverView: UIView!     //遊び方説明画面
    
    @IBAction func nextButton_coverView(_ sender: Any) {
        coverView.isHidden = true
        getPixabayImages()    //外部API(pixabay)に検索ワードを投げて画像を得て、それを表示してタイマーも開始するメソッド
        count = 31
        odaiNumber = 1
        commentNumber = 0
        odaiImageNumber = 0
        odaiLabel.text = "\(odaiNumber)題目"
        commentTextView.isEditable = true
        tabBarController?.tabBar.isHidden = true  //プレイ中はtabBarを非表示にする
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        odaiLabel.text = "\(odaiNumber)題目"       //何題目なのか表示
        tabBarController?.tabBar.isHidden = true  //tabBarを非表示
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        coverView.isHidden = false
        
        if let user = Auth.auth().currentUser {
                    if user.isAnonymous == false {
                        tabBarController?.tabBar.isHidden = false  //登録者ならtabBarを表示
            }else{
                        tabBarController?.tabBar.isHidden = true   //匿名者ならtabBarを非表示
            }
        }
        
        if isFirstPlay == false{  //匿名者でも初playじゃなければtabBarを表示
            tabBarController?.tabBar.isHidden = false
            print("初playでないならtabBarを表示WillAppear")
        }
    }
    
    
    // パラメータ作成 (パラメータとheader情報はkey/valueのDictionaryで設定する。これはAlamofireの仕様)
    private func getPixabayImages() {
        let parameters: [String: Any] = [
            "key": self.apiKey,
            "q": "\(wordsList.wordsA.randomElement()!)+\(wordsList.wordsB.randomElement()!)",
            "per_page": 200
        ]
        
        print("q:\(parameters["q"])")
        
        let headers:HTTPHeaders = [              //HTTPHeadersはURLリクエストに適用するヘッダーの辞書
            "Contenttype": "application/json"    //リクエストを送信してレスポンスを受け取る際のフォーマットを指定してる
        ]
        
        self.fire(params: parameters, headers: headers)
    }
    
    
    // APIをコールする
    private func fire(params: [String: Any], headers: [String: String]) {
        Alamofire.request(self.baseUrl,
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.queryString,
                          headers: headers)
            .responseData { (response) in
                self.result(response: response)
        }
    }
    
    
    //配列"hits"のcountを取得し、0件とそうでない場合で処理を分ける
    private func result(response: DataResponse<Data>) {
        let json :JSON = JSON(response.data as Any)
        let totalHitsCount = json ["hits"].array?.count  //そのワードで検索して得られた画像の数がtotalHitsCount
        
        print("totalHitsCount1=\(totalHitsCount)")
        
        // 0件だった場合、再度APIコールし処理を終了(return)
        if totalHitsCount == 0 {
            self.getPixabayImages()
            return  //メソッドから抜ける
        }
        switch response.result {
        case .success:
            guard let data = response.data else { fatalError() }  //fatalError()でエラーを発生させ意図的にアプリを落とす
            self.displayImage(data: data)
            break
            
        case .failure(let error):
            print(error.localizedDescription)//print(error)だとエラーコードなど概要しか出力されないからlocalizedDescriptionで詳細も出す
            break
        }
    }
    
    
    //totalHitsCountからランダムの数値を出し、totalHitsRandomNumber番目の画像を取得してodaiImageViewに反映する
    private func displayImage(data: Data) {
        let json :JSON = JSON(data as Any)
        let totalHitsCount = json ["hits"].array?.count
        
        print("totalHitsCount2=\(totalHitsCount)")
        
        let totalHitsRandomNumber = Int.random(in: 0..<totalHitsCount!)
        
        print("totalHitsRandomNumber:\(totalHitsRandomNumber)")
        
        guard let imageString = json ["hits"][totalHitsRandomNumber]["webformatURL"].string else { return }
        
        //4題答え終わったら新しい画像を表示しなくていいため
        if 1...4 ~= odaiNumber {
            
            self.odaiImageView.sd_setImage(with: URL(string: imageString), completed: { (image, err, cacheType, url) in
                print(err?.localizedDescription as Any)
            })  //コールバック
            
            startTimer()
        }
    }
    
    
    //次のお題に行った際にラベルを更新する
    private func odaiLabelIncrement() {
        switch odaiNumber {
            
            case 1:
                odaiNumber = 2
                odaiLabel.text = "\(odaiNumber)題目"
            
            case 2:
                odaiNumber = 3
                odaiLabel.text = "\(odaiNumber)題目"
            
            case 3:
                odaiNumber = 4
                odaiLabel.text = "\(odaiNumber)題目"
            
            //4題答え終わったらodaiLabelとtimerLabelを消すため。
            case 4:
                odaiNumber = 5
                odaiLabel.text = ""
                timerLabel.text = ""
            
        default: break
        }
    }
    
    
    //それぞれのお題画像をstroageのそれぞれのフォルダに保存できるようにnext押すたびインクリメント
    private func odaiImageNumberIncrement() {
        
        switch odaiImageNumber {
            
            case 0:
                odaiImageNumber = 1
            
            case 1:
                odaiImageNumber = 2
            
            case 2:
                odaiImageNumber = 3
            
            case 3:
                odaiImageNumber = 4
            
        default: break
        }
    }
    
    
    //それぞれの回答をドキュメントのそれぞれのフィールドに保存できるようにnext押すたびインクリメント
    private func commentNumberIncrement() {
        
        switch commentNumber {
            
            case 0:
                commentNumber = 1
            
            case 1:
                commentNumber = 2
            
            case 2:
                commentNumber = 3
            
            case 3:
                commentNumber = 4
            
        default: break
        }
    }
    
    
    func takeScreenShot() {
        
        //幅・高さを決める
        let width = view.bounds.width
        let height = view.bounds.height
        let size  = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //viewに書き出す
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        switch odaiNumber {  //それぞれのお題に答える都度、スクショをそれぞれの変数に入れる
            case 1:
                screenShotImagae1 = UIGraphicsGetImageFromCurrentImageContext()!
            
            case 2 :
                screenShotImagae2 = UIGraphicsGetImageFromCurrentImageContext()!
            
            case 3 :
                screenShotImagae3 = UIGraphicsGetImageFromCurrentImageContext()!
            
            case 4 :
                screenShotImagae4 = UIGraphicsGetImageFromCurrentImageContext()!
            
            default: break
            }
        
        UIGraphicsEndImageContext()
        odaiLabelIncrement()          //スクショを撮るたび、お題のラベルの更新とcommentTextViewを空に
        commentTextView.text = ""
    }
    
    
    //スクショをtwitterにシェア
    func share() {
        
        let items = ["#画像で雑大喜利",
                 "https://apps.apple.com/jp/app/%E7%94%BB%E5%83%8F%E3%81%A7%E9%9B%91%E5%A4%A7%E5%96%9C%E5%88%A9/id1498900431",
                     screenShotImagae1,
                     screenShotImagae2,
                     screenShotImagae3,
                     screenShotImagae4] as [Any]
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        //iPadでActivityViewControllerを出すため
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0,
                                                                      y: self.view.bounds.size.height / 2.0,
                                                                      width: 1.0,
                                                                      height: 1.0)
        
        present(activityVC, animated: true, completion: nil)
    }

    
    //時間制限
    func startTimer() {
        
        //4題答え終わったらodaiLabelとtimerLabelを消すため
        if 1...4 ~= odaiNumber {
        //タイマーを回す
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCount), userInfo: nil, repeats: true)
        //timeInterval: 何秒ごとに呼ぶのか/target: どこのメソッドを呼ぶか/selector: なんのメソッドを呼ぶのか
        //つまり、1秒ごとに自身のクラスのtimerUpdateメソッドを呼ぶ
        }
    }
    
    
    //回答すると呼ばれるタイマーメソッド
    @objc func timerCount() {
        
        if 1...31 ~= count {
            count = count - 1
        }else{
            count = 0
        }
        
        if count == 0 {
            
            //タイムオーバーしたら強制的に次の問題に行く
            self.next(nextButton as Any)
        }
        timerLabel.text = "\(count)秒"
    }
    
    
    //storageにお題の画像を保存
    func odaiImageAdd() {
        
        // ログインされていること確認する
        guard let user = Auth.auth().currentUser else { return }
        
        //ストレージサーバのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/")
        
        // パス  /  画像のURLが「uid.jpeg」となるように保存
        let imageRef = storage.child("odaiImageNumber\(odaiImageNumber)").child("\(user.uid).jpeg")
        
        //保存したい画像のデータを変数として持つ
        var odaiImageData: Data = Data()
        
        if odaiImageView.image != nil {  //odaiImageViewに画像があれば
            
            odaiImageData = (odaiImageView.image?.jpegData(compressionQuality: 0.01))!  //画像を圧縮して代入
            
        }else{  //お題の画像が見つける前に回答されたら、odaiImageDataにデフォの画像をいれる
            odaiImageData = (UIImage(named: "image8")!.jpegData(compressionQuality: 0.01))!
        }
        
        //storageに画像を送信
        imageRef.putData(odaiImageData, metadata: nil) { (metaData, error) in
            
            //エラーであれば
            if error != nil {
                print(error.debugDescription)
                return  //これより下にはいかないreturn
            }
        }
    }
    
    
    //ドキュメントにコメントとpostedAtを追加する
    func commentAdd() {
        
        //時刻を取得する
        let dt = Date()
        let dateFormatter = DateFormatter()
        //日付の書式＆日本時間にする
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMddHHmm", options: 0, locale: Locale(identifier: "ja_JP"))
        
        let date = dateFormatter.string(from: dt)
        
        // ログインされていること確認する
        guard let userID = Auth.auth().currentUser?.uid else { fatalError() }
        
        var commentText:String
        
        if tempCommentText != nil{
            commentText = tempCommentText!
            
            if commentTextView.hasText == false{  //commentTextViewにテキストがなかったら
                commentText = "未回答またはタイムオーバー"
            }
            
            ref = db.collection("users").document(userID)
            
            ref?.setData ([
                "comment\(commentNumber)": commentText,
                "postedAt": date], merge: true) { error in
                    
                if let error = error {
                    print("Error setData document: \(error)")
                } else {
                    print("Document successfully setData")
                }
            }
        }
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        getPixabayImages()                //外部API(pixabay)に検索ワードを投げて画像を得て、それを表示してタイマーも開始するメソッド
        odaiImageNumberIncrement()
        commentNumberIncrement()
        count = 31                        //カウントを31に設定し直す
        timer.invalidate()                //現在のタイマーを無効にする
        commentAdd()                      //ドキュメントに回答を保存
        odaiImageAdd()                    //storageにお題画像を保存
        takeScreenShot()                  //スクショ撮影
        nextButton.isEnabled = false //nextButtonを押せなくする
        
        if odaiNumber == 5 {              //4題目のお題に答え終わったら
            share()                       //Twitter連携などできるアクティビティービューを出す
            validate()                    //ボタンとTextViewの非活性
            isFirstPlay = false           //匿名ユーザーでもisFirstPlay = falseならtabbarが表示される
            print("isFirstPlay = falseにした")
            tabBarController?.tabBar.isHidden = false  //非表示にしていたタブバーを復活させる
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
    
    private func validate() {  //ボタンとTextViewの非活性

        self.commentTextView.isEditable = false
        self.nextButton.isEnabled = false
    }
}


// MARK: UITextViewDelegate
extension PlayViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.tempCommentText = textView.text
        
        if tempCommentText!.count == 0 {  //textViewが空なら
            self.nextButton.isEnabled = false
        }else{
            self.nextButton.isEnabled = true
        }
    }
}
