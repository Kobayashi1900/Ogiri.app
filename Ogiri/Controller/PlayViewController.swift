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
    
    private var tempCommentText: String?
    
    
    private let wordsList = WordsList()  //インスタンス生成、語群にアクセスできる
    var timer = Timer()  //timerクラスのインスタンス生成
    private var count = 30
    private var odaiNumber = 1
    private var screenShotImagae = UIImage()  //スクショを入れる変数
    let db = Firestore.firestore()
    
    private let baseUrl = "https://pixabay.com/api/"
    private let apiKey = "13787747-8afd4e03ae250892260a92055"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPixabayImages()
        self.startTimer()
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
    
    
    
    
    
    private func result(response: DataResponse<Data>) {
        let json :JSON = JSON(response.data)
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
    
    
    
    
    
    private func displayImage(data: Data) {
        let json :JSON = JSON(data as Any)
        let totalHitsCount = json ["hits"].array?.count
        
        print("totalHitsCount2=\(totalHitsCount)")
        
        let totalHitsRandomNumber = Int.random(in: 0..<totalHitsCount!)
        
        print("totalHitsRandomNumber=\(totalHitsRandomNumber)")
        
        guard let imageString = json ["hits"][totalHitsRandomNumber]["webformatURL"].string else { return }
        
        self.odaiImageView.sd_setImage(with: URL(string: imageString), completed: { (image, err, cacheType, url) in
            print(err?.localizedDescription as Any)
        })  //コールバック
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
        screenShotImagae = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    
    }
    
    //時間制限
    func startTimer() {
        
        //タイマーを回す
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCount), userInfo: nil, repeats: true)
        //timeInterval: 何秒ごとに呼ぶのか
        //target: どこのメソッドを呼ぶか
        //selector: なんのメソッドを呼ぶのか
        // ＝　1秒ごとに自身のクラスのtimerUpdateメソッドを呼ぶ
        
    }
    
    
    //回答すると呼ばれるタイマーメソッド
    @objc func timerCount() {
        
        if 1...30 ~= count {
            
            count = count - 1
            
        }else{
            
            count = 0
            
        }
        
        timerLabel.text = "\(count)秒"
        
    }
    
    //ドキュメントにコメントを追加する
    func commentAdd() {
        
        var ref: DocumentReference? = nil
        
        // ログインされていること確認する
        guard let userID = Auth.auth().currentUser?.uid else { fatalError() }
        
        if let commentText = self.tempCommentText {
            
            ref = db.collection("users").document(userID)
            
            ref?.setData ([
                "comment": commentText], merge: true) { error in
                    
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
        odaiLabelIncrement()
        commentTextView.text = ""
        count = 30
        timer.invalidate()
        startTimer()
        commentAdd()
        
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
        self.commentTextView.text = textView.text
        self.tempCommentText = textView.text
    }
}
