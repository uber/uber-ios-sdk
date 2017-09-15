Pod::Spec.new do |s|

  s.name         = "UberRides"
  s.version      = "0.7.0"
  s.summary      = "The Official Uber Rides iOS SDK."
  s.description  = <<-DESC
    This Swift library allows you to integrate Uber into your iOS app. It is designed to make it quick and easy to add a 'Request a Ride' button in your application, seamlessly connecting your users with Uber.
                   DESC
  s.homepage     = "https://github.com/uber/rides-ios-sdk"
  s.screenshots  = "https://raw.githubusercontent.com/uber/rides-ios-sdk/master/img/example_app.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Edward Jiang" => "edjiang@uber.com", "Jay Bobzin" => "jbobzin@uber.com", "Ty Smith" => "tys@uber.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/uber/rides-ios-sdk.git", :tag => 'v' + s.version.to_s }
  s.source_files = ["source/UberRides/**/*.{swift,h,m}"]
  s.resource     = "source/UberRides/Resources/**"
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

end
