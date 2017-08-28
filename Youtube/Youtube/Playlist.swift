//
//  Playlist.swift
//  Youtube
//
//  Created by MAC on 8/25/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import RealmSwift


class Playlist {
    var id = ""
    var title = ""
    var urlImage = ""
    var channelTitle = ""
    var videos = [Video]()
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    
}

