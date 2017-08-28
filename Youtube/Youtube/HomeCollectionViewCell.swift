//
//  HomeCollectionViewCell.swift
//  Youtube
//
//  Created by MAC on 8/25/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!

    func loadData(video: Video) {
        title.text = video.title
        image.tmSetImage(url: video.urlImage)
    }

    override func awakeFromNib() {
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 10
    }
}
