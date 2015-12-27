//
//  RBAlbum.swift
//  AKQARockboxController
//
//  Created by Jon Reiling on 9/7/14.
//  Copyright (c) 2014 AKQA. All rights reserved.
//

import Foundation
import SwiftyJSON

public class RBAlbum : RBBase {
    
    public var albumArtworkURL:String!
    public var albumArtworkThumbnailURL:String!
    public var tracks:[RBTrack]?
    
    init( json: JSON ) {
        super.init()
        
        albumArtworkURL = ""
        albumArtworkThumbnailURL = ""
        type = "album"
        populateFromJSON(json)
    }
    
    override public func populateFromJSON( json : JSON ) {
        
        super.populateFromJSON(json)
        
        if let jsonAlbumURI = json["images"][0]["url"].string {
            self.albumArtworkURL = jsonAlbumURI
        }
        
        if let jsonAlbumThumbnailURI = json["images"][2]["url"].string {
            self.albumArtworkThumbnailURL = jsonAlbumThumbnailURI
        }
        
        if let jsonTracks = json["tracks"]["items"].array {
            
            var tracks:[RBTrack] = []
            
            for jsonTrack in jsonTracks {

                let track:RBTrack = RBTrack(json:jsonTrack);
                track.album = self
                
                tracks.append(track)
            }
            
            self.tracks = tracks
            
        }
        
    }

}