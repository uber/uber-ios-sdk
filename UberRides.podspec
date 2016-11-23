Pod::Spec.new do |s|

  s.name         = "UberRides"
  s.version      = "0.6.0"
  s.summary      = "The Official Uber Rides iOS SDK."
  s.description  = <<-DESC
    This Swift library allows you to integrate Uber into your iOS app. It is designed to make it quick and easy to add a 'Request a Ride' button in your application, seamlessly connecting your users with Uber.
                   DESC
  s.homepage     = "https://github.com/uber/rides-ios-sdk"
  s.screenshots  = "https://raw.githubusercontent.com/uber/rides-ios-sdk/master/img/example_app.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Christine Kim" => "christinek@uber.com", "Farwa Naqi" => "farwa@uber.com", "John Brophy" => "jbrophy@uber.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/uber/rides-ios-sdk.git", :tag => 'v' + s.version.to_s }
  s.source_files = ["source/UberRides/*.swift", "source/UberRides/Model/*.swift", "source/UberRides/OAuth/*.swift", "source/UberRides/Utilities/*.swift"]
  s.resource     = "source/UberRides/Resources/**"
  s.requires_arc = true
  s.dependency 'ObjectMapper', '~> 1.0'

end
