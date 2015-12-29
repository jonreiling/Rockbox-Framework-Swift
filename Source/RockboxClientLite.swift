//
//  RockboxClientLite.swift
//  Rockbox-Framework-Swift
//
//  Created by Jon Reiling on 12/29/15.
//  Copyright © 2015 Reiling. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


public class RockboxClientLite : RockboxBase {
    
    public static let sharedInstance = RockboxClientLite()
    
    public func update( success:()->Void , fail: (error:NSError) -> Void) {
        
        Alamofire.request(.GET, server + "/api/fullstatus" ).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    
                    if let jsonPlaying = json["state"]["playing"].bool {
                        self.isPlaying = jsonPlaying
                    }
                    if let jsonRadio = json["state"]["radio"].bool {
                        self.radioMode = jsonRadio
                    }
                    
                    if let jsonVolume = json["volume"]["volume"].int {
                        self.volume = jsonVolume
                    }
                    
                    if let jsonConnectedToPlayer = json["connectedToPlayer"].bool {
                        self.passthroughConnection = jsonConnectedToPlayer
                    }
                    
                    self.queue = []
                    
                    if let jsonQueue = json["queue"].array {
                        for jsonTrack in jsonQueue {
                            self.queue.append( RBTrack(json:jsonTrack) )
                        }
                    }
                    
                    print(json);
                    
                    
                }
            case .Failure(let error):
                fail(error: error)
            }
        }
    }
    

    
    
}