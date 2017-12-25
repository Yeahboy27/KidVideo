//
//  AllPlaylistViewController.swift
//  Youtube
//
//  Created by MAC on 8/31/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import FSPagerView
import GoogleSignIn
import GoogleAPIClientForREST

class AllPlaylistViewController: UIViewController {
    let service = GTLRYouTubeService()
    var allPlaylists = [Playlist]()
    let scopes = [kGTLRAuthScopeYouTubeReadonly]
    let signInButton = GIDSignInButton()
    var channelId = ""
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        let type = FSPagerViewTransformerType.coverFlow
        self.pagerView.transformer = FSPagerViewTransformer(type:type)

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AllPlaylistViewController: GIDSignInDelegate, GIDSignInUIDelegate  {
    func initView() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        view.addSubview(signInButton)
        pagerView.delegate = self
        pagerView.dataSource = self
        self.pagerView.itemSize = CGSize(width: 220, height: 170)

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            debugPrint(error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchDataWithChannelId(id: allChannelId[0])
        }
    }
    
    func fetchDataWithChannelId(id: String) {
        APIClient.shared.getAllPlaylistForChannel(id: id) {[weak self] (playlists) in
            self?.allPlaylists = playlists
            self?.pagerView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? AllChannelTableViewController {
            des.selectedChannelDelegate = self
            des.channelIdSelected = self.channelId
        }
    }

}

extension AllPlaylistViewController: FSPagerViewDataSource,FSPagerViewDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return allPlaylists.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.tmSetImage(url: allPlaylists[index].urlImage)
        cell.textLabel?.text = allPlaylists[index].title
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailController = storyboard.instantiateViewController(withIdentifier: "DetailPlaylistViewController") as! DetailPlaylistViewController
        detailController.idPlaylist = allPlaylists[index].id
        show(detailController, sender: nil)
    }
}

extension AllPlaylistViewController: SelectedChannelDelegate {
    func changeChannel(channelId: String) {
        self.channelId = channelId
        fetchDataWithChannelId(id: channelId)
    }
}


