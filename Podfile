source 'https://github.com/CocoaPods/Specs'

platform :ios, '7.0'

workspace 'UberSDK'

xcodeproj 'UberSDK/UberSDK.xcodeproj'
target 'UberSDKTests' do
  xcodeproj 'UberSDK/UberSDK.xcodeproj'

  pod 'UberSDK', :path => '.'
  pod 'OHHTTPStubs', '~> 4.0'
end

xcodeproj 'Example/UberSDK-Example.xcodeproj'
target 'UberSDK-Example' do
  xcodeproj 'Example/UberSDK-Example.xcodeproj'

  pod 'UberSDK', :path => '.'
  pod 'BlocksKit', '~> 2.2'
  pod 'MRProgress', '~> 0.7'
end
