//
//  TableViewCell.swift
//  Ogiri
//
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseUI

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
        

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    private func loadProfileImage() {

        //ログインされていることを確認する
        guard let user = Auth.auth().currentUser else { return }

        //StorageのURLを参照
        let storageref = Storage.storage().reference(forURL: "gs://ogiri-d1811.appspot.com)").child("profileImage").child("\(user.uid).jpeg")

        profileImageView.sd_setImage(with: storageref)

    }
    
    
    
}
