Pod::Spec.new do |s|

  s.name         = "UberRides"
  s.version      = "0.1.0"
  s.summary      = "The Official Uber Rides iOS SDK."
  s.description  = <<-DESC
    This Swift library allows you to integrate Uber into your iOS app. It is designed to make it quick and easy to add a 'Request a Ride' button in your application, seamlessly connecting your users with Uber.
                   DESC
  s.homepage     = "https://github.com/uber/rides-ios-sdk"
  s.screenshots  = "https://github.com/uber/rides-ios-sdk/tree/master/img/example_app"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Christine Kim" => "christinek@uber.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/uber/rides-ios-sdk.git", :tag => s.version }
  s.source_files = "source/UberRides/*.swift"
  s.resources    = "source/UberRides/Media.xcassets/Badge.imageset/*.png"
  s.requires_arc = true

end
