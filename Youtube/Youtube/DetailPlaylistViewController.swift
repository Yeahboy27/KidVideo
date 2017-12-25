//
//  DetailPlaylistViewController.swift
//  Youtube
//
//  Created by MAC on 8/26/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import SnapKit
import RealmSwift

class DetailPlaylistViewController: UIViewController {
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewTab: UIView!
    @IBOutlet weak var mutilWidth: NSLayoutConstraint!
    @IBOutlet weak var mutilHeight: NSLayoutConstraint!
    @IBOutlet weak var sliderVideo: UISlider!
    @IBOutlet weak var endDurationLabel: UILabel!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var handleModeVideo: UIButton!
    @IBOutlet weak var nextVideoButton: UIButton!
    @IBOutlet weak var previousVideoButton: UIButton!
    @IBOutlet weak var video: YTPlayerView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIButton!
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
    var isPlaying = false {
        didSet {
            if isPlaying {
                video.playVideo()
                handleModeVideo.setImage(#imageLiteral(resourceName: "detail_pause"), for: .normal)
            } else {
                video.pauseVideo()
                handleModeVideo.setImage(#imageLiteral(resourceName: "detail_start"), for: .normal)
            }
        }
    }
    var currentTimeVideo: Float = 0
    var timer = Timer()
    var videoIdPlaying = "" {
        didSet {
            sliderVideo.value = 0
            handleModeVideo.setImage(#imageLiteral(resourceName: "detail_start"), for: .normal)
        }
    }
    var allIdVideo: [String] = []
    var dataCollection: [Video] = []
    var allVideo = [Video]()
    var idPlaylist = ""
    
    // for search
    var typeSource: SourceToDetail = SourceToDetail.playlist
    var titleSearch: String = ""
    
    // for favorite
    var isFavorite = false
    
    internal var videoPlaying = Video()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        getData()
        initView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playingVideo(_ sender: Any) {
        isPlaying = !isPlaying
        addVideoToHistory(id: videoIdPlaying)
    }
    
    @IBAction func restartVideo(_ sender: Any) {
        video.loadVideo(byId: videoIdPlaying, startSeconds: 0, suggestedQuality: .auto)
    }
    @IBAction func fullScreenVideo(_ sender: Any) {
        mutilWidth = mutilWidth.setMultiplier(multiplier : 1)
        mutilHeight = mutilHeight.setMultiplier(multiplier : 1)
        setUpFullScreen()
    }
    
    @IBAction func handleFavorite(_ sender: Any) {
        if isFavorite {
            deleteVideoToFavorite(id: videoIdPlaying)
            favoriteButton.setImage(#imageLiteral(resourceName: "detail_unfavorite"), for: .normal)
        } else {
            addVideoToFavorite(id: videoIdPlaying)
            favoriteButton.setImage(#imageLiteral(resourceName: "detail_favorite"), for: .normal)
        }
        isFavorite = !isFavorite
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextVideo(_ sender: Any) {
        videoIdPlaying = dataCollection[indexVideoSelected + 1].id
        video.load(withVideoId: videoIdPlaying)
        indexVideoSelected = indexVideoSelected + 1
        collectionView.reloadData()
    }
   
    @IBAction func previousVideo(_ sender: Any) {
        videoIdPlaying = dataCollection[indexVideoSelected - 1].id
        video.load(withVideoId: videoIdPlaying)
        indexVideoSelected = indexVideoSelected - 1
        collectionView.reloadData()
    }
    
    @IBAction func cueVideo(_ sender: Any) {
        video.loadVideo(byId: videoIdPlaying, startSeconds: Float(video.duration())*sliderVideo.value, suggestedQuality: .default)
        currentDurationLabel.text = Int(Float(video.duration()) * sliderVideo.value).convertFromSecondToTime()
    }
}

extension DetailPlaylistViewController {
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
    
    func addVideoToFavorite(id: String) {
        let realm = try! Realm()
        let videoFavorite = VideoFavorite()
        videoFavorite.id = id
        APIClient.shared.getDataVideo(id: id) { (video) in
            videoFavorite.title = video.title
            videoFavorite.urlImage = video.urlImage
            try! realm.write {
                realm.add(videoFavorite)
            }
        }
    }
    
    func deleteVideoToFavorite(id: String) {
        let realm = try! Realm()
        if let videoDelete = realm.objects(VideoFavorite.self).filter("id == %@", id).first {
            try! realm.write {
                realm.delete(videoDelete)
            }
        }
    }
    
    func checkFavoriteVideo(id: String) {
        let realm = try! Realm()
        let theVideo = realm.objects(VideoFavorite.self).filter("id = %@", id)
        if theVideo.count > 0 {
            favoriteButton.imageView?.image = #imageLiteral(resourceName: "detail_favorite")
            isFavorite = true
        } else {
            favoriteButton.imageView?.image = #imageLiteral(resourceName: "detail_unfavorite")
            isFavorite = false
        }
    }
    
    func initView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        video.delegate = self
        previousVideoButton.isHidden = true
        checkFavoriteVideo(id: videoIdPlaying)
    }
    
    func getData() {
        switch typeSource {
        case .search: getDataFromSearch()
        default: getDataPlaylist()
        }
    }
    
    func getDataPlaylist() {
        APIClient.shared.getDataForPlaylist(idPlaylist: idPlaylist) { [unowned self] (playlist) in
            self.dataCollection = playlist.videos
            self.dataCollection = self.dataCollection.map({ (video) -> Video in
                return video
            })
            self.allIdVideo = self.dataCollection.map({ (video) -> String in
                return video.id
            })
            APIClient.shared.getDataVideo(id: self.allIdVideo[0], completion: { (video) in
                self.videoPlaying = video
                self.endDurationLabel.text = String(video.duration.convertFromSecondToTime())
            })
            self.videoIdPlaying = self.dataCollection[0].id
//            self.video.load(withVideoId: self.videoIdPlaying, playerVars:  ["playsinline": "1", "controls": "0", "fs":"0", "auxtoplay":"1", "showinfo": "0", "disablekb": "f", "modestbranding": "1"])
            self.video.load(withVideoId: self.videoIdPlaying)
            self.video.currentTime()
            self.collectionView.reloadData()
        }
    }
    
    func getDataFromSearch() {
//        self.video.load(withVideoId: videoPlaying.id, playerVars:  ["playsinline": "1", "controls": "0", "fs":"0", "auxtoplay":"1", "showinfo": "0", "disablekb": "f", "modestbranding": "1"])
        self.video.load(withVideoId: videoPlaying.id)
        self.videoIdPlaying = videoPlaying.id
        APIClient.shared.searchForTitleWithChannel(title: titleSearch, maxResult: 30, channelId: videoPlaying.channelId) {[unowned self] (allvideo) in
            self.dataCollection = allvideo
            self.allIdVideo = self.dataCollection.map({ (video) -> String in
                return video.id
            })
            APIClient.shared.getDataVideo(id: self.allIdVideo[0], completion: { (video) in
                self.videoPlaying = video
                self.endDurationLabel.text = String(video.duration.convertFromSecondToTime())
            })
            self.video.currentTime()
            self.collectionView.reloadData()
        }
    }
    
}

extension DetailPlaylistViewController {
    func outSide() {
        mutilHeight = mutilHeight.setMultiplier(multiplier: 0.7)
        mutilWidth = mutilWidth.setMultiplier(multiplier: 0.6)
        setUpDisFullScreen()
    }
    
    func setUpFullScreen() {
        self.viewTab.isHidden = false
        self.view.bringSubview(toFront: viewTab)
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(self.outSide))
        viewTab.addGestureRecognizer(gestureOutside)
        backButton.isHidden = true
        collectionView.isHidden = true
        controlView.isHidden = true
        video.loadVideo(byId: videoIdPlaying, startSeconds: currentTimeVideo, suggestedQuality: .default)
    }
    
    func setUpDisFullScreen() {
        updateCurrentTimeVideo()
        backButton.isHidden = false
        collectionView.isHidden = false
        collectionView.isHidden = false
        controlView.isHidden = false
        viewTab.gestureRecognizers?.removeAll()
        viewTab.isHidden = true
    }
    
    func checkStatusVideo(state: YTPlayerState) {
        switch(state) {
        case .playing, .buffering, .queued:
            handleModeVideo.setImage(#imageLiteral(resourceName: "detail_pause"), for: .normal)
        case .paused, .unknown, .ended:
            handleModeVideo.setImage(#imageLiteral(resourceName: "detail_start"), for: .normal)
        default:
            handleModeVideo.setImage(#imageLiteral(resourceName: "detail_start"), for: .normal)
            break
        }
    }
    
    func updateCurrentTimeVideo() {
        currentDurationLabel.text = Int(video.currentTime()).convertFromSecondToTime()
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
            indexVideoSelected = indexPath.row
            videoIdPlaying = dataCollection[indexPath.row].id
            videoPlaying = Video(id: videoIdPlaying)
            video.load(withVideoId: videoIdPlaying)
            checkFavoriteVideo(id: videoIdPlaying)
            collectionView.reloadData()
    }
    
    func updateNewVideo() {
        checkStatusVideo(state: video.playerState())
        currentDurationLabel.text = "0:00"
        endDurationLabel.text = Int(video.duration()).convertFromSecondToTime()
    }
}

extension DetailPlaylistViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        checkStatusVideo(state: state)
        switch(state) {
        case .playing:
            countTimeControl()
        default:
            timer.invalidate()
        }
    }
    
    func countTimeControl() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timePlus), userInfo: nil, repeats: true)
    }
    
    func timePlus() {
        currentDurationLabel.text = Int(video.currentTime()).convertFromSecondToTime()
        currentTimeVideo = video.currentTime()
        sliderVideo.value = currentTimeVideo/Float(video.duration())
    }
}



