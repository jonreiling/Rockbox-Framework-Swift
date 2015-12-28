Pod::Spec.new do |s|
  s.name         = "Rockbox-Framework-Swift"
  s.version      = "0.0.1"
  s.summary      = "This is my summary"
  s.homepage     = "https://github.com/jonreiling/Rockbox-Framework-Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jon Reiling" => "jreiling@mac.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.10"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  
  s.source       = { :git => "https://github.com/jonreiling/Rockbox-Framework-Swift.git" }
  s.source_files  = "Source/**/*.swift"

  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'Socket.IO-Client-Swift', '~> 4.1.6'
  s.dependency 'SwiftyJSON', '2.3.2'
  s.framework    = 'Rockbox_Framework_Swift'
end
