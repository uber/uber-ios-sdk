Pod::Spec.new do |s|
  s.name = "UberSDK"
  s.version = "1.0.0"
  s.summary = "An open-source SDK for interacting with Uber's public API."
  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.homepage = "https://github.com/uber/UberSDK-iOS"
  s.authors = { 'Uber API Team' => 'uber-api-support@uber.com' }
  s.source = { :git => "https://github.com/uber/UberSDK-iOS.git", :tag => "v#{s.version.to_s}" }
  s.requires_arc = true

  s.ios.deployment_target = "7.0"

  s.frameworks  = "Foundation"

  s.subspec "Core" do |sp|
    sp.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*.{h,m}"
    sp.dependency 'Mantle', '~> 1.4'
  end

  s.subspec "REST" do |sp|
    sp.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*.{h,m}", "#{s.name}/#{s.name}/#{sp.base_name}/Classes/Models/**/*.{h,m}"
    sp.ios.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/iOS/*.{h,m}"

    sp.dependency 'UberSDK/Core'
    sp.dependency 'Mantle', '~> 1.4'
  end

  s.subspec "OAuth2" do |sp|
    sp.ios.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/iOS/*.{h,m}"

    sp.dependency 'UberSDK/Core'
  end

  s.source_files = "#{s.name}/#{s.name}/*.{h,m}"
end
