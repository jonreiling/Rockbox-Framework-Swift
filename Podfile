#source 'https://github.com/CocoaPods/Specs.git'
#platform :ios, '8.0'
#platform :tvos, '9.0'
#platform :osx, '10.10'
#use_frameworks!

#pod 'Alamofire', '~> 3.0'
#pod 'Socket.IO-Client-Swift', '~> 4.1.6'
#pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'



# Podfile

use_frameworks!

# Available pods

def available_pods
	pod 'Alamofire', '~> 3.0'
	pod 'Socket.IO-Client-Swift', '~> 4.1.6'
	pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
end

target 'Rockbox-Framework-OSX', :exclusive => false do
	platform :osx, '10.10'
	available_pods
end

target 'Rockbox-Framework-iOS', :exclusive => false do
	platform :ios, '8.0'
    available_pods
end

target 'Rockbox-Framework-tvOS', :exclusive => false do
	platform :tvos, '9.0'
    available_pods
end

target 'Rockbox-Framework-watchOS', :exclusive => false do
	platform :watchos, '2.0'
	pod 'Alamofire', '~> 3.0'
	pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
end



ENV['COCOAPODS_DISABLE_DETERMINISTIC_UUIDS'] = 'true'