//
//  APIClient + Search.swift
//  Youtube
//
//  Created by MAC on 10/4/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

extension APIClient {
    func searhcForTitleVideo(title: String, completion:  @escaping(_ aplaylist: [Video]) -> Void) {
        var countComplete = 0
        var resultSearch = [Video]()
        
        for i in 0...allChannelId.count  - 1 {
            let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
            query.channelId = allChannelId[0]
            query.type = "video"
            query.q = title
            query.maxResults = 15
            service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
            query.channelId = allChannelId[i]
            DispatchQueue.main.async {
                APIClient.shared.service.executeQuery(query) { (ticket, object, error) in
                    if error != nil {
                        return
                    }
                    if let respone = object as? GTLRYouTube_SearchListResponse {
                        if let items = respone.items {
                            for video in items {
                                guard let id = video.identifier?.videoId else {
                                    fatalError()
                                }
                                guard let title = video.snippet?.title else {
                                    fatalError()
                                }
                                guard let thumbail = video.snippet?.thumbnails?.medium?.url else {
                                    fatalError()
                                }
                                guard let channelId = video.snippet?.channelId else {
                                    fatalError()
                                }
                                let video = Video(id: id)
                                video.title = title
                                video.urlImage = thumbail
                                video.channelId = channelId
                                resultSearch.append(video)
                            }
                        }
                    }
                    countComplete += 1
                    if(countComplete == allChannelId.count) {
                        completion(resultSearch)
                    }
                }
            }
        }
    }
    
    func searchForTitleWithChannel(title: String,maxResult: Int,channelId: String, completion:  @escaping(_ aplaylist: [Video]) -> Void) {
        var resultSearch = [Video]()
        let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        query.channelId = channelId
        query.type = "video"
        query.q = title
        query.maxResults = UInt(maxResult)
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        DispatchQueue.main.async {
            APIClient.shared.service.executeQuery(query) { (ticket, object, error) in
                if error != nil {
                    return
                }
                if let respone = object as? GTLRYouTube_SearchListResponse {
                    if let items = respone.items {
                        for video in items {
                            guard let id = video.identifier?.videoId else {
                                fatalError()
                            }
                            guard let title = video.snippet?.title else {
                                fatalError()
                            }
                            guard let thumbail = video.snippet?.thumbnails?.medium?.url else {
                                fatalError()
                            }
                            let video = Video(id: id)
                            video.title = title
                            video.urlImage = thumbail
                            resultSearch.append(video)
                        }
                    }
                }
                completion(resultSearch)
            }
        }
    }
}
