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
    
    let wordsList = WordsList()  //インスタンス生成、語群にアクセスできる
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImages()

    }
    

    
    
    
    
    
    
    
    //画像を引っ張ってくる(pixabay.com)
    func getImages() {
        
        let parameter: String = "\(wordsList.wordsA.randomElement()!)+\(wordsList.wordsB.randomElement()!)"
        //"\(wordsList.wordsA.randomElement()!)+\(wordsList.wordsB.randomElement()!)"
        
        //APIKEY  13787747-8afd4e03ae250892260a92055
        let url = "https://pixabay.com/api/?key=13787747-8afd4e03ae250892260a92055&q=\(parameter)"
        
        print("parameter:\(parameter)")
        
        //Alamofireを使ってhttpリクエストをgetで投げる({}内の結果がresponseに入ってくる)
        Alamofire.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default).responseJSON { (response) in
            
            //responseに値が帰ってきて、それをJSON解析を行う
            switch response.result {
                
                //responseに値が入っていた時
                case .success:
                    //ここでデータを取得しjsonに代入
                    let json :JSON = JSON(response.data as Any)
                    
                    //"totalHits"の値(数字)を取り出す
//                    var totalHitsCount = json ["totalHits"].int
                    var totalHitsCount = json ["hits"].array?.count
                    
                    print("totalHitsCount:\(totalHitsCount)")
                    
                    //////////////////////////totalHitsCountが0だった場合
                    if totalHitsCount == 0 {

                        let url = "https://pixabay.com/api/?key=13787747-8afd4e03ae250892260a92055&q=funny"

                        Alamofire.request(url,
                        method: .get,
                        parameters: nil,
                        encoding: JSONEncoding.default).responseJSON { (response) in

                            switch response.result {

                                case .success:
                                        let json :JSON = JSON(response.data as Any)
                                        var totalHitsCount = json ["hits"].array?.count
                                        var totalHitsRandomNumber = Int.random(in: 0..<totalHitsCount!)
                                        var imageString = json ["hits"][totalHitsRandomNumber]["webformatURL"].string

                                        self.odaiImageView.sd_setImage(with: URL(string: imageString!), completed: nil)

                                case .failure(let error):
                                        print(error)
                            }
                        }
                    }//////////////////////////totalHitsCountが0だった場合
                    
                    var totalHitsRandomNumber = Int.random(in: 0..<totalHitsCount!)
                    
                    print("totalHitsRandomNumber:\(totalHitsRandomNumber)")
                    
                    //画像のURLをimageStringに入れる(配列hitsのキー値"webformatURL"で保存されている値を取ってくる)
                    var imageString = json ["hits"][totalHitsRandomNumber]["webformatURL"].string
                    
                    print("imageString:\(imageString)")
                    
                        //画像のURLが入ったimageStringをodaiImageViewに表示
                        //string型のimageStringをURL型にキャストしなければいけない↓
                        self.odaiImageView.sd_setImage(with: URL(string: imageString!), completed: nil)
                
                //responseに値が入ってない時
                case .failure(let error):

                    print(error)
                
            }
        
        }
            
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        getImages()

        
    }
    
}

//totalHitsNumberが0~1だった時の処理
