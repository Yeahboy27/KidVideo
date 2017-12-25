//
//  ViewController.swift
//  Youtube
//
//  Created by MAC on 8/22/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import FSPagerView

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var allVideo: [Video] = []
    let service = GTLRYouTubeService()
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    let signInButton = GIDSignInButton()

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchData()
        }
    }
    
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData() {
        let query = GTLRYouTubeQuery_PlaylistsList.query(withPart: "snippet,contentDetails")
        query.channelId = "UC5ezaYrzZpyItPSRG27MLpg"
        query.maxResults = 50
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_PlaylistListResponse,
        error : NSError?) {
        
        if let error = error {
            debugPrint(error)
            print(error)
            return
        }
        
        if let items = response.items {
            for playlist in items {
                guard let id = playlist.identifier else {
                    fatalError()
                }
                allVideo.append(Video(id: id))
            }
        }
        collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if allVideo.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? HomeCollectionViewCell
        cell?.loadData(video: allVideo[indexPath.row])
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let detailViewController = segue.destination as? DetailPlaylistViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedPlaylistCell = sender as? HomeCollectionViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = collectionView.indexPath(for: selectedPlaylistCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let playlistSelected = allVideo[indexPath.row]
        detailViewController.idPlaylist = playlistSelected.id
    }
}





