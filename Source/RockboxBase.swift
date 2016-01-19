//
//  RockboxBase.swift
//  Rockbox-Framework-Swift
//
//  Created by Jon Reiling on 12/29/15.
//  Copyright © 2015 Reiling. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class RockboxBase {
 
    internal var connected:Bool = false
    internal var server:String!
    internal var volume:Int = 50
    internal var isPlaying : Bool = false
    internal var radioMode : Bool = false
    internal var passthroughConnection : Bool = false
    internal var queue : [RBTrack] = []
    
    public init() {}
    public func getVolume() -> Int { return volume }
    public func getIsPlaying() -> Bool { return isPlaying }
    public func getRadioMode() -> Bool { return radioMode }
    public func getConnected() -> Bool { return connected }
    public func getQueue() -> [RBTrack] { return queue }
    
    public func setPassthroughServer(server:String) {
        self.server = server
    }
    
    //MARK: -
    //MARK: Rockbox API functions
    
    public func add(id:String) {
        Alamofire.request(.GET, server + "/api/add/" + id)
    }
    
    public func togglePlayPause() {
        Alamofire.request(.GET, server + "/api/pause")
    }
    
    public func skip() {
        Alamofire.request(.GET, server + "/api/skip")
    }
    
    public func setRadio(radioOn:Bool) {
        
        if ( radioOn ) {
            Alamofire.request(.GET, server + "/api/radio/on")
        } else {
            Alamofire.request(.GET, server + "/api/radio/off")
        }
    }
    
    public func setVolume(vol:AnyObject) {
        Alamofire.request(.GET, server + "/api/volume/" + String(vol) )
    }
    
    //MARK: -
    //MARK: Spotify API functions
    
    public func search(searchTerm:String, success: (tracks :[RBTrack],albums:[RBAlbum],artists:[RBArtist]) ->() , fail: (error:NSError) -> Void ) {
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?type=artist,album,track", parameters: ["q":searchTerm,"limit":40] ).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    var tracks:[RBTrack] = []
                    var albums:[RBAlbum] = []
                    var artists:[RBArtist] = []
                    
                    if let jsonTracks = json["tracks"]["items"].array {
                        for jsonTrack in jsonTracks {
                            tracks.append( RBTrack(json:jsonTrack) )
                        }
                    }
                    
                    if let jsonAlbums = json["albums"]["items"].array {
                        for jsonAlbum in jsonAlbums {
                            albums.append( RBAlbum(json:jsonAlbum) )
                        }
                    }
                    
                    if let jsonArtists = json["artists"]["items"].array {
                        for jsonArtist in jsonArtists {
                            artists.append( RBArtist(json:jsonArtist) )
                        }
                    }
                    success(tracks: tracks, albums: albums, artists: artists)
                    
                    
                }
            case .Failure(let error):
                fail(error: error)
                print(error)
            }
        }
        
    }
    
    public func fetchAlbum(albumId:String, success:(album:RBAlbum) -> () , fail: (error:NSError) -> Void) {
        
        let cleanedAlbumId = albumId.stringByReplacingOccurrencesOfString("spotify:album:", withString: "")
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/albums/" + cleanedAlbumId ).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    let album:RBAlbum = RBAlbum(json:json)
                    success(album: album)
                }
                
            case .Failure(let error):
                fail(error: error)
            }
        }
        
    }
    
    public func fetchArtist(artistId:String, success:(artist:RBArtist) -> ()  , fail: (error:NSError) -> Void) {
        
        let cleanedArtistId = artistId.stringByReplacingOccurrencesOfString("spotify:artist:", withString: "")
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/artists/" + cleanedArtistId ).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    let artist:RBArtist = RBArtist(json:json)
                    
                    //Artist objects have to be fetched in two parts. The first is to get the basic info.
                    //The second is to get the albums.
                    self.fetchArtistAlbums(cleanedArtistId, artist: artist, success: success)
                    
                }
            case .Failure(let error):
                fail(error: error)
            }
        }
    }
    
    private func fetchArtistAlbums(artistId:String,artist:RBArtist, success:(artist:RBArtist) -> Void ) {
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/artists/" + artistId + "/albums/?album_type=album&market=US&limit=50" ).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    artist.populateFromJSON(json)
                    success(artist: artist)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}