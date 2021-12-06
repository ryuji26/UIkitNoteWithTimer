//
//  ThumbnailCollectionViewCell.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/12/05.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    /// Set up the view initially.
    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds).cgPath
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.clipsToBounds = false
    }
}

