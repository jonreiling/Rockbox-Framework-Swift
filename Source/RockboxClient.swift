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

public class RockboxClient : RockboxBase {

    public static let sharedInstance = RockboxClient()
    private var socket:SocketIOClient!
    
    
    override init() {}
    
    public func connect() {
        setupSockets()
        socket.connect()
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    
    //MARK: -
    //MARK: Rockbox API functions
    
    override public func add(id:String) {

        if ( connected ) {
            self.socket.emit("add", id)
        } else {
            super.add(id)
        }
    }
    
    override public func togglePlayPause() {
        
        if ( connected ) {
            self.socket.emit("pause")
        } else {
            super.togglePlayPause()
        }
    }
    
    override public func skip() {
        
        if ( connected ) {
            self.socket.emit("skip")
        } else {
            super.skip()
        }
    }
    
    override public func setRadio(radioOn:Bool) {
        
        if ( connected ) {
            self.socket.emit("setRadio",radioOn)
        } else {
            
            super.setRadio(radioOn)
        }
    }
    
    override public func setVolume(vol:AnyObject) {
        if ( connected ) {
            self.socket.emit("setVolume",vol)
        } else {
            super.setVolume(vol)
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