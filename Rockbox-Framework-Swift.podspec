Pod::Spec.new do |s|
  s.name         = "Rockbox-Framework-Swift"
  s.version      = "0.0.1"
  s.summary      = ""
  s.homepage     = "https://github.com/jonreiling/Rockbox-Framework-Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jon Reiling" => "jreiling@mac.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  
  s.source       = { :git => "https://github.com/jonreiling/Rockbox-Framework-Swift.git" }
  s.source_files  = "Source/**/*.swift"

end