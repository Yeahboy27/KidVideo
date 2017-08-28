//
//  DetailPlaylistCollectionViewCell.swift
//  Youtube
//
//  Created by MAC on 8/27/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit

class DetailPlaylistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbailVideo: UIImageView!
    
    override func awakeFromNib() {
        thumbailVideo.layer.cornerRadius = 5
    }
    
    func loadData(video: Video) {
        thumbailVideo.tmSetImage(url: video.urlImage)
    }
}
