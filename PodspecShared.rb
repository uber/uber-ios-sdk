def configure_podspec(spec, module_name)
  spec.name         = module_name
  spec.version      = "0.14.0"
  spec.summary      = "The Official Uber Rides iOS SDK."
  spec.description  = <<-DESC
    This Swift library allows you to integrate Uber into your iOS app. It is designed to make it quick and easy to add a 'Request a Ride' button in your application, seamlessly connecting your users with Uber.
                   DESC
  spec.homepage     = "https://github.com/uber/rides-ios-sdk"
  spec.screenshots  = "https://raw.githubusercontent.com/uber/rides-ios-sdk/master/img/example_app.png"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.authors      = { "Edward Jiang" => "edjiang@uber.com", "Jay Bobzin" => "jbobzin@uber.com", "Ty Smith" => "tys@uber.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/uber/rides-ios-sdk.git", :tag => 'v' + spec.version.to_s }
  spec.source_files = ["source/" + module_name + "/**/*.{swift,h,m}"]
  spec.swift_version = '4.2'
  spec.resource     = "source/" + module_name + "/Resources/**"
  spec.requires_arc = true
  spec.ios.deployment_target = '11.0'
end
