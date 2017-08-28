//
//  DetailPlaylistViewController.swift
//  Youtube
//
//  Created by MAC on 8/26/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailPlaylistViewController: UIViewController {
    
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var endDurationLabel: UILabel!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var handleModeVideo: UIButton!
    @IBOutlet weak var nextVideoButton: UIButton!
    @IBOutlet weak var previousVideoButton: UIButton!
    @IBOutlet weak var video: YTPlayerView!
    @IBOutlet weak var collectionView: UICollectionView!
    var indexVideoSelected = 0 {
        didSet {
            if indexVideoSelected == 0 {
                previousVideoButton.isHidden = true
            } else {
                previousVideoButton.isHidden = false
            }
            if dataCollection.count  > 0 {
                if indexVideoSelected + 1 == dataCollection.count {
                    nextVideoButton.isHidden = true
                } else {
                    nextVideoButton.isHidden = false
                }
            }
        }
    }
    var videoIdPlaying = ""
    var allIdVideo: [String] = []
    var dataCollection: [Video] = []
    var allVideo = [Video]()
    var idPlaylist = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIClient.shared.getVideo(idPlaylist: idPlaylist) { [unowned self] (videos) in
            self.dataCollection = videos
            self.allIdVideo = self.dataCollection.map({ (video) -> String in
                return video.id
            })
            self.videoIdPlaying = self.dataCollection[0].id
            self.video.load(withVideoId: self.videoIdPlaying, playerVars:  ["playsinline": "1", "controls": "0", "fs":"0", "autoplay":"1", "showinfo": "0", "disablekb": "f", "modestbranding": "1"])
            self.video.currentTime()
//            self.video.load(withVideoId: self.videoIdPlaying)
            self.collectionView.reloadData()
        }
        
        initView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fullScreenVideo(_ sender: Any) {
    }
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextVideo(_ sender: Any) {
        video.load(withVideoId: dataCollection[indexVideoSelected + 1].id)
        indexVideoSelected = indexVideoSelected + 1
        collectionView.reloadData()
    }
   
    @IBAction func previousVideo(_ sender: Any) {
        video.load(withVideoId: dataCollection[indexVideoSelected - 1].id)
        indexVideoSelected = indexVideoSelected - 1
        collectionView.reloadData()
    }
}

extension DetailPlaylistViewController {
    func initView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        previousVideoButton.isHidden = true
    }
}

extension DetailPlaylistViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if dataCollection.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailPlaylistCell", for: indexPath) as! DetailPlaylistCollectionViewCell
        cell.loadData(video: dataCollection[indexPath.row])
        if indexPath.row == indexVideoSelected {
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.red.cgColor
        } else {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let indexVideoPlaying = allIdVideo.index(of: videoIdPlaying) {
            let cell = collectionView.cellForItem(at: IndexPath(item: Int(indexVideoPlaying), section: 0)) as? DetailPlaylistCollectionViewCell
            cell?.layer.borderWidth = 1
            cell?.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        indexVideoSelected = indexPath.row
        videoIdPlaying = dataCollection[indexPath.row].id
        video.load(withVideoId: videoIdPlaying)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2
        cell?.layer.borderColor = UIColor.red.cgColor
    }
}
