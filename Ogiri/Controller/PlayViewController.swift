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

class PlayViewController: UIViewController {
    
    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    private let wordsList = WordsList()  //インスタンス生成、語群にアクセスできる
    private var count = 0
    
    private let baseUrl = "https://pixabay.com/api/"
    private let apiKey = "13787747-8afd4e03ae250892260a92055"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPixabayImages()
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


    
    
    @IBAction func next(_ sender: Any) {
        
        self.getPixabayImages()
        
    }
    
}

