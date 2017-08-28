//
//  APIClient.swift
//  Youtube
//
//  Created by MAC on 8/25/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class APIClient {
    let service = GTLRYouTubeService()
    static let shared = APIClient()
    
    func getVideo(idPlaylist: String, completion:  @escaping(_ allVideo: [Video]) -> Void) {
        var allVideo: [Video] = []
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: "snippet,contentDetails")
        query.playlistId = idPlaylist
        query.maxResults = 50
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        service.executeQuery(query) { (tiket, object, error) in
            if error != nil {
                return
            }
            if let respone = object as? GTLRYouTube_PlaylistItemListResponse {
                if let items = respone.items {
                    for video in items {
                        guard let id = video.contentDetails?.videoId else {
                            fatalError()
                        }
                        guard let urlImage = video.snippet?.thumbnails?.medium?.url else {
                            fatalError()
                        }
                        guard let title = video.snippet?.title else {
                            fatalError()
                        }
                        allVideo.append(Video(id: id, urlImage: urlImage, title: title))
                    }
                }
            }
            completion(allVideo)
        }
    }
    
    func getDataVideo(id: String, completion: @escaping(_ video: Video) -> ()) {
        let _video = Video()
        let query = GTLRYouTubeQuery_VideosList.query(withPart: "snippet,contentDetails,statistics")
        query.identifier = id
        query.maxResults = 1
        service.authorizer  = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query) { (ticket, object, error) in
            if error != nil {
                return
            }
            if let respone = object as? GTLRYouTube_VideoListResponse {
                if let item = respone.items {
                    guard let title = item[0].snippet?.title else  {
                        fatalError()
                    }
                    guard let urlImage = item[0].snippet?.thumbnails?.medium?.url else {
                        fatalError()
                    }
                    guard let duration = item[0].contentDetails?.duration else {
                        fatalError()
                    }
                    _video.title = title
                    _video.urlImage = urlImage
                    _video.duration = duration.dateComponents().convertToSecond()
                }
            }
            completion(_video)
        }
    }

}
   
