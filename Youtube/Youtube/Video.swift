//
//  Video.swift
//  Youtube
//
//  Created by MAC on 8/25/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import RealmSwift
import UIKit


class Video {
    var id = ""
    var urlImage = ""
    var title = ""
    var duration = -1
    
    convenience init(id: String, urlImage : String, title: String) {
        self.init()
        self.id = id
        self.urlImage = urlImage
        self.title = title
    }
    
    func getDataVideo() {
        APIClient.shared.getDataVideo(id: self.id) { (video) in
            self.urlImage = video.urlImage
            self.title = video.title
            self.duration = video.duration
        }
    }
}
