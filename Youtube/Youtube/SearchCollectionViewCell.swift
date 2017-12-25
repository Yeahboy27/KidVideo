//
//  SearchCollectionViewCell.swift
//  Youtube
//
//  Created by MAC on 10/11/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    
    
    internal func loadData(video: Video) {
        self.layer.cornerRadius = 15
        img.tmSetImage(url: video.urlImage)
        title.text = video.title
    }
}
