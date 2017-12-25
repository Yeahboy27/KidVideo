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
    var channelId = ""
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
}

class VideoFavorite: Object {
    @objc dynamic var id = ""
    @objc dynamic var urlImage = ""
    @objc dynamic var title = ""
}

class VideoHistory: Object {
    @objc dynamic var id = ""
    @objc dynamic var urlImage = ""
    @objc dynamic var title = ""
}

class Channel: Object {
    @objc dynamic var id = ""
}



