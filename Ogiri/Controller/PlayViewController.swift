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
    
    private var tempCommentText: String?
    
    
    private let wordsList = WordsList()  //インスタンス生成、語群にアクセスできる
    var timer = Timer()  //timerクラスのインスタンス生成
    private var count = 31
    private var odaiNumber = 1
    var commentNumber = 0
    var odaiImageNumber = 0
    private var screenShotImagae1 = UIImage() //スクショを入れる配列
    private var screenShotImagae2 = UIImage() //スクショを入れる配列
    private var screenShotImagae3 = UIImage() //スクショを入れる配列
    private var screenShotImagae4 = UIImage() //スクショを入れる配列
    let db = Firestore.firestore()
    
    private let baseUrl = "https://pixabay.com/api/"
    private let apiKey = "13787747-8afd4e03ae250892260a92055"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPixabayImages()
        odaiLabel.text = "\(odaiNumber)題目"
        self.commentTextView.delegate = self
        
    }
    
    
    
    
    
    // パラメータ作成 (パラメーターとheader情報はkey/valueのDictionaryで設定する。これはAlamofireの仕様)
    private func getPixabayImages() {
        let parameters: [String: Any] = [
            "key": self.apiKey,
            "q": "\(wordsList.wordsA.randomElement()!)+\(wordsList.wordsB.randomElement()!)",
            "per_page": 200
        ]
        
        print("q=\(parameters["q"])")
        
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
        let totalHitsCount = json ["hits"].array?.count
        
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
    
    
    
    
    //totalHitsCountからランダムの数値を出し、totalHitsCount番目の画像を取得してodaiImageViewに反映する
    private func displayImage(data: Data) {
        let json :JSON = JSON(data as Any)
        let totalHitsCount = json ["hits"].array?.count
        
        print("totalHitsCount2=\(totalHitsCount)")
        
        let totalHitsRandomNumber = Int.random(in: 0..<totalHitsCount!)
        
        print("totalHitsRandomNumber=\(totalHitsRandomNumber)")
        
        guard let imageString = json ["hits"][totalHitsRandomNumber]["webformatURL"].string else { return }
        
        //4題答え終わったら新しい画像を表示しなくていいため
        if 1...4 ~= odaiNumber {
            
            self.odaiImageView.sd_setImage(with: URL(string: imageString), completed: { (image, err, cacheType, url) in
                print(err?.localizedDescription as Any)
            })  //コールバック
            
            startTimer()
            
        }
        
    }
    
    
    
    
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
            
        default:
            break
        }
        
    }
    
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
            
        default:
            break
        }
        
    }
    
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
            
        default:
            break
        }
        
    }
    
    
    func takeScreenShot() {
        
        //幅・高さを決める
        let width = CGFloat(UIScreen.main.bounds.size.width)
        let height = CGFloat(UIScreen.main.bounds.size.height)
        let size  = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //viewに書き出す
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        switch odaiNumber {
            case 1:
                screenShotImagae1 = UIGraphicsGetImageFromCurrentImageContext()!
            
            case 2 :
                screenShotImagae2 = UIGraphicsGetImageFromCurrentImageContext()!
            
            case 3 :
                screenShotImagae3 = UIGraphicsGetImageFromCurrentImageContext()!
            
            case 4 :
                screenShotImagae4 = UIGraphicsGetImageFromCurrentImageContext()!
            
            default:
                break
            }
        
        UIGraphicsEndImageContext()
        odaiLabelIncrement()
        commentTextView.text = ""
    
    }
    
    
    //スクショをtwitterにシェア
    func share() {
        
        let items = [screenShotImagae1,
                     screenShotImagae2,
                     screenShotImagae3,
                     screenShotImagae4] as [Any]
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
        
    }
    
    
    
    
    //時間制限
    func startTimer() {
        
        //4題答え終わったらodaiLabelとtimerLabelを消すため
        if 1...4 ~= odaiNumber {
        //タイマーを回す
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCount), userInfo: nil, repeats: true)
        //timeInterval: 何秒ごとに呼ぶのか
        //target: どこのメソッドを呼ぶか
        //selector: なんのメソッドを呼ぶのか
        // ＝　1秒ごとに自身のクラスのtimerUpdateメソッドを呼ぶ
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
    
    
    func odaiImageAdd() {
        
        // ログインされていること確認する
        guard let user = Auth.auth().currentUser else { return }
        
        //ストレージサーバのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com/")
        
        // パス
        let imageRef = storage.child("odaiImageNumber\(odaiImageNumber)").child("\(user.uid).jpeg")
        
        //保存したい画像のデータを変数として持つ
        var odaiImageData: Data = Data()
        
        if odaiImageView.image != nil {
            
        //画像を圧縮
        odaiImageData = (odaiImageView.image?.jpegData(compressionQuality: 0.01))!
            
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
    
    
    
    //ドキュメントにコメントを追加する
    func commentAdd() {
        
        var ref: DocumentReference? = nil
        //時刻を取得する
        let dt = Date()
        let dateFormatter = DateFormatter()
        //日付の書式＆日本時間にする
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHm", options: 0, locale: Locale(identifier: "ja_JP"))
        
        let date = dateFormatter.string(from: dt)
        
        // ログインされていること確認する
        guard let userID = Auth.auth().currentUser?.uid else { fatalError() }
        
        if let commentText = self.tempCommentText {
            
            ref = db.collection("users").document(userID)
            
            ref?.setData ([
                "comment\(commentNumber)": commentText], merge: true) { error in
                    
                if let error = error {
                    print("Error setData document: \(error)")
                } else {
                    print("Document successfully setData")
                }
                    
            }
            
            ref?.setData ([
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
        
        self.getPixabayImages()
        odaiImageNumberIncrement()
        commentNumberIncrement()
        count = 31
        timer.invalidate()
        commentAdd()
        odaiImageAdd()
        takeScreenShot()
        self.nextButton.isEnabled = false
        
        if odaiNumber == 5 {
            
            share()
            
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
    
    
}



// MARK: UITextViewDelegate
extension PlayViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.tempCommentText = textView.text
        
        if tempCommentText!.count == 0 {
        
            self.nextButton.isEnabled = false
                
        }else{
            
            self.nextButton.isEnabled = true
            
        }
        
    }
    
}
