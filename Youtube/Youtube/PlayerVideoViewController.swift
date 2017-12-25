//
//  PlayerVideoViewController.swift
//  Youtube
//
//  Created by MAC on 12/18/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import RealmSwift

class PlayerVideoViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playerVideo: YTPlayerView!
    var idVideo: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        playerVideo.load(withVideoId: idVideo)
        playerVideo.playVideo()
        addVideoToHistory(id: idVideo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addVideoToHistory(id: String) {
        let realm = try! Realm()
        let video = realm.objects(VideoHistory.self).filter("id == %@", id)
        if(video.count > 0) {
            try! realm.write {
                realm.delete(video.first!)
            }
        }
        let videoRecent = VideoHistory()
        videoRecent.id = id
        APIClient.shared.getDataVideo(id: id) { (video) in
            videoRecent.title = video.title
            videoRecent.urlImage = video.urlImage
            try! realm.write {
                realm.add(videoRecent)
            }
        }
    }
   
}
