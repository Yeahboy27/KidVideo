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
    var _completion : ((Bool) -> Void)?
    
    func getDataForPlaylist(idPlaylist: String, completion:  @escaping(_ aplaylist: Playlist) -> Void) {
        let playlist = Playlist(id: idPlaylist)
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
                        guard let videoId = video.contentDetails?.videoId else {
                            fatalError()
                        }
                        if let thumbails  = video.snippet?.thumbnails?.medium?.url {
                            let aVideo = Video(id: videoId)
                            aVideo.urlImage = thumbails
                            playlist.videos.append(aVideo)
                        } else {
                            let aVideo = Video(id: videoId)
                            playlist.videos.append(aVideo)
                        }
                    }
                }
            }
            completion(playlist)
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
    
    func getAllPlaylistForChannel(id: String, completion: @escaping(_ playlists: [Playlist]) -> ()) {
        var playlists = [Playlist]()
        let query = GTLRYouTubeQuery_PlaylistsList.query(withPart: "snippet,contentDetails")
        query.channelId = id
        query.maxResults = 50
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        APIClient.shared.service.executeQuery(query) { (ticket, object, error) in
            if error != nil {
                return
            }
            if let respone = object as? GTLRYouTube_PlaylistListResponse {
                if let item = respone.items {
                    for playlist in item {
                        guard let id = playlist.identifier else {
                            fatalError()
                        }
                        guard let title = playlist.snippet?.title else {
                            fatalError()
                        }
                        if let thumbail = playlist.snippet?.thumbnails?.high?.url {
                            let _playlist = Playlist(id: id)
                            _playlist.urlImage = thumbail
                            _playlist.title = title
                            playlists.append(_playlist)
                        } else {
                              let _playlist = Playlist(id: id)
                              _playlist.title = title
                              playlists.append(_playlist)
                        }
                       
                    }
                }
            }
            completion(playlists)
        }
    }
    
}
   
