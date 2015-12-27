//
//  RBTrack.swift
//  AKQARockboxController
//
//  Created by Jon Reiling on 9/7/14.
//  Copyright (c) 2014 AKQA. All rights reserved.
//

import Foundation
import SwiftyJSON

public class RBTrack : RBBase {
    
    public var artist:RBArtist!
    public var album:RBAlbum!

    init( json : JSON ) {
        super.init()

        type = "track"
        populateFromJSON(json)
    }
    
    override public func populateFromJSON( json : JSON ) {

        super.populateFromJSON(json)
        
        //if let albumJSON = json["album"] {
            album = RBAlbum(json: json["album"])
        //}
        
      //  if let artistJSON = json["artists"][0] {
            artist = RBArtist(json: json["artists"][0])
        //}
    }
}