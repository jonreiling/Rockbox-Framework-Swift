#Rockbox-Framework-Swift

Rockbox-Framework-Swift is a cross-platform framework for integrating with Rockbox, a communal jukebox built on node.

## Requirements

- iOS 8.0+ / Mac OS X 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 7

##Dependencies

- [Socket.IO-Client-Swift](https://github.com/nuclearace/Socket.IO-Client-Swift)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

##Integration

####CocoaPods (iOS 8+, OS X 10.9+)

Add the following to your Podfile

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
	pod 'Rockbox-Framework-Swift', :git => 'https://github.com/jonreiling/Rockbox-Framework-Swift.git'
end
```
Note: if you are compiling for both iOS and watchOS, you will need to set "deduplicate_targets: false" in ~/.cocoapods/config.yaml (don't be surprised if this hasn't be created yet.)

##Usage

####Standard Usage (uses Sockets)

```swift

import Rockbox_Framework_Swift

NSNotificationCenter.defaultCenter().addObserverForName(RockboxEvent.Queue, object: nil, queue: nil) { (_) -> Void in
    
    let queue = RockboxClient.sharedInstance.getQueue()
    
    if (queue.count == 0 ) {
        print("nothing is playing")
    } else {
        let track = queue.first!
        print(track.name)
    }
}

RockboxClient.sharedInstance.setPassthroughServer("http://localhost:3000")
RockboxClient.sharedInstance.connect()
```


####Lite Usage (uses REST)

In cases where sockets aren't necessary, or available. (watchOS, for example.) In this case, you will need to call `update` in order to fetch the latest values. Polling may be added in the future, but for now, this assumes a quick-hit look at state data.

```swift
import Rockbox_Framework_Swift

RockboxClientLite.sharedInstance.setPassthroughServer("http://localhost:3000")

RockboxClientLite.sharedInstance.update({ () -> Void in
    
        let queue = RockboxClientLite.sharedInstance.getQueue()
        
        if (queue.count == 0 ) {
            print("nothing is playing")
        } else {
            let track = queue.first!
            print(track.name)
        }
    
    }) { (error) -> Void in
        print(error)
}

```