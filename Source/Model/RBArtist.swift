//
//  RBArtist.swift
//  AKQARockboxController
//
//  Created by Jon Reiling on 9/7/14.
//  Copyright (c) 2014 AKQA. All rights reserved.
//

import Foundation
import SwiftyJSON

public class RBArtist : RBBase {
    
    public var artistArtworkURL:String?
    public var artistArtworkThumbnailURL:String?
    public var albums:[RBAlbum]?
    
    init( json: JSON ) {
        super.init()
        
        type = "artist"
        populateFromJSON(json)
    }
    
    override public func populateFromJSON( json : JSON ) {
        
        super.populateFromJSON(json)
        
        if let jsonArtworkURI = json["images"][0]["url"].string {
            self.artistArtworkURL = jsonArtworkURI
        }
        
        if let jsonArtistThumbnailURI = json["images"][2]["url"].string {
            self.artistArtworkThumbnailURL = jsonArtistThumbnailURI
        }
        
        if let jsonAlbums = json["items"].array {
            
            var albums:[RBAlbum] = []
            
            for jsonAlbum in jsonAlbums {
                
                let album:RBAlbum = RBAlbum(json:jsonAlbum);
                albums.append(album)
            }
            
            self.albums = albums
            
        }
    }
    
    
}