//
//  RBBase.swift
//  AKQARockboxController
//
//  Created by Jon Reiling on 9/7/14.
//  Copyright (c) 2014 AKQA. All rights reserved.
//

import Foundation
import SwiftyJSON

public class RBBase {
    
    public var name:String!
    public var id:String!
    public var uri:String!
    public var type:String!
    
    init() {
        type = "base"
    }
    
    public func populateFromJSON( json : JSON ) {
        
        if let jsonName = json["name"].string {
            name = jsonName
        }

        if let jsonURI = json["uri"].string {
            uri = jsonURI
        }

        if let jsonId = json["id"].string {
            id = jsonId
        }

    }
}