//
//  RockboxClient.swift
//  Rockbox-Client-Swift
//
//  Created by Jon Reiling on 12/25/15.
//  Copyright © 2015 AKQA. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import Alamofire
import SwiftyJSON

public struct Rockbox {
    public struct Updates {
        public static let State = "kRockboxStateUpdate"
        public static let Volume = "kRockboxVolumeUpdate"
        public static let Queue = "kRockboxQueueUpdate"
        public static let PassthroughConnection = "kRockboxPassthroughConnectionUpdate"
    }
}

public class RockboxClient {

    public static let sharedInstance = RockboxClient()
    
    private var connected:Bool = false
    private var socket:SocketIOClient!
    private var server:String!
    private var volume:Int = 50
    private var isPlaying : Bool = false
    private var radioMode : Bool = false
    private var passthroughConnection : Bool = false
    private var queue : [RBTrack] = []
    
    public init() {}
    public func getVolume() -> Int { return volume }
    public func getIsPlaying() -> Bool { return isPlaying }
    public func getRadioMode() -> Bool { return radioMode }
    public func getConnected() -> Bool { return connected }
    public func getQueue() -> [RBTrack] { return queue }
    
    public func setPassthroughServer(server:String) {
        self.server = server
    }
    
    public func connect() {
        setupSockets()
        socket.connect()
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    //MARK: -
    //MARK: Rockbox API functions
    
    
    public func add(id:String) {
        self.socket.emit("add", id)
    }
    
    public func togglePlayPause() {
        
        if ( connected ) {
            self.socket.emit("pause")
        } else {
            Alamofire.request(.GET, server + "/api/pause")
        }
    }
    
    public func skip() {
        
        if ( connected ) {
            self.socket.emit("skip")
        } else {
            Alamofire.request(.GET, server + "/api/skip")
        }
    }
    
    public func setRadio(radioOn:Bool) {
        
        if ( connected ) {
            self.socket.emit("setRadio",radioOn)
        } else {
            
            if ( radioOn ) {
                Alamofire.request(.GET, server + "/api/radio/on")
            } else {
                Alamofire.request(.GET, server + "/api/radio/off")
            }
        }
    }
    
    public func setVolume(vol:AnyObject) {
        if ( connected ) {
            self.socket.emit("setVolume",vol)
        } else {
            Alamofire.request(.GET, server + "/api/volume/" + String(vol) )
        }
    }

    //MARK: -
    //MARK: Spotify API functions
    
    public func search(searchTerm:String, success: (tracks :[RBTrack],albums:[RBAlbum],artists:[RBArtist]) ->() , fail: (error:NSError) -> () ) {
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?type=artist,album,track", parameters: ["q":"ratatat","limit":40] ).validate().responseJSON { response in
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
    
    public func fetchAlbum(albumId:String, success:(album:RBAlbum) -> () , fail: (error:NSError) -> ()) {
        
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
    
    public func fetchArtist(artistId:String, success:(artist:RBArtist) -> ()  , fail: (error:NSError) -> ()) {
        
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

    private func fetchArtistAlbums(artistId:String,artist:RBArtist, success:(artist:RBArtist) -> () ) {
        
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
    
    private func setupSockets() {
        
        socket = SocketIOClient(socketURL: server, options: [.Log(false),.Nsp("/rockbox-client"), .ForcePolling(true)])

        socket.on("connect") {data, ack in
            print("socket connected")
            self.connected = true;
        }

        socket.on("disconnect") {data, ack in
            print("socket disconnected")
            self.connected = false;
        }
        
        socket.on("queueUpdate") {data, ack in

            let json:JSON = JSON(data[0])
            var tracks:[RBTrack] = []
            
            if let jsonTracks = json["queue"].array {
                for jsonTrack in jsonTracks {
                    tracks.append( RBTrack(json:jsonTrack) )
                }
            }
            
            self.queue = tracks
            
            NSNotificationCenter.defaultCenter().postNotificationName(Rockbox.Updates.Queue, object: nil);
            
        }

        socket.on("stateUpdate") {data, ack in

            let json:JSON = JSON(data[0])
            
            if let isPlaying = json["playing"].bool {
                self.isPlaying = isPlaying
            }
            
            if let radioMode = json["radio"].bool {
                self.radioMode = radioMode
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Rockbox.Updates.State, object: nil);
        }
        
        socket.on("volumeUpdate") {data, ack in

            let json:JSON = JSON(data[0])
            if let volume = json["volume"].int {
                self.volume = volume
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Rockbox.Updates.Volume, object: nil);
        
        }

        socket.on("passthroughConnectionUpdate") {data, ack in

            let json:JSON = JSON(data[0])
            
            if let passthroughConnection = json["connected"].bool {
                self.passthroughConnection = passthroughConnection
            }

            NSNotificationCenter.defaultCenter().postNotificationName(Rockbox.Updates.PassthroughConnection, object: nil);
        }

    }
    
    
}