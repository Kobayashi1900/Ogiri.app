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

        //.dequeueReusableCell - 識別子がついたセルのサイズを変更する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        return cell
        
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return view.frame.size.height/2
        
    }


}
