//
//  TimeLineViewController.swift
//  Ogiri
//
//  Created by kobayashi on 2019/10/08.
//  Copyright © 2019 kobayashi riku. All rights reserved.
//

import UIKit

class TimeLineViewController:
        UIViewController{
//      UITableViewDelegate,
//      UITableViewDataSource {




    @IBOutlet weak var timeLineTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        timeLineTableView.delegate = self
//        timeLineTableView.dataSource = self

    }

    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }


//    //セクションの中のセルの数(必須)
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//
//
//    }
//
//    //セルをどうやって構築するか(必須)
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//
//
//    }



}
