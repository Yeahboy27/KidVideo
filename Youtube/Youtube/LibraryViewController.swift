//
//  LibraryViewController.swift
//  Youtube
//
//  Created by MAC on 12/17/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import FSPagerView
import RealmSwift

class LibraryViewController: UIViewController {
    
    var allVideo = [Video]()
    var videosHistory = [Video]()
    var videosFavorite = [Video]()
    
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpValue()
    }
    
    @IBAction func segmentHandle(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            allVideo = videosHistory
        } else {
            allVideo = videosFavorite
        }
        reloadPagerView()
    }


}

extension LibraryViewController {
    func initView() {
        setUpValue()
        self.pagerView.itemSize = CGSize(width: 220, height: 170)
        let type = FSPagerViewTransformerType.invertedFerrisWheel
        self.pagerView.transformer = FSPagerViewTransformer(type:type)
        pagerView.dataSource = self
        pagerView.delegate = self
    }
    
    func setUpValue() {
        let realm = try! Realm()
        if realm.objects(VideoHistory.self).count > 0 {
            let videoFromRealm = realm.objects(VideoHistory.self)
            for _video in videoFromRealm {
                let _videoHistory = Video()
                _videoHistory.id = _video.id
                _videoHistory.urlImage = _video.urlImage
                _videoHistory.title = _video.title
                videosHistory.append(_videoHistory)
            }
        }
        if realm.objects(VideoFavorite.self).count > 0 {
            let videoFromRealm = realm.objects(VideoFavorite.self)
            for _video in videoFromRealm {
                let _videoFavorite = Video()
                _videoFavorite.id = _video.id
                _videoFavorite.urlImage = _video.urlImage
                _videoFavorite.title = _video.title
                videosFavorite.append(_videoFavorite)
            }
        }
        reloadPagerView()
    }
}

extension LibraryViewController: FSPagerViewDataSource,FSPagerViewDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return allVideo.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.tmSetImage(url: allVideo[index].urlImage)
        cell.textLabel?.text = allVideo[index].title
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailController = storyboard.instantiateViewController(withIdentifier: "PlayerVideoViewController") as! PlayerVideoViewController
        detailController.idVideo = allVideo[index].id
        show(detailController, sender: nil)
    }
    
    func reloadPagerView() {
        if segment.selectedSegmentIndex == 0 {
            pagerView.transformer = FSPagerViewTransformer(type: .invertedFerrisWheel)
        } else {
            pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
        }
        pagerView.reloadData()
    }
}
