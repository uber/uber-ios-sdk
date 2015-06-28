Pod::Spec.new do |s|
  s.name = "UberSDK"
  s.version = "0.0.1"
  s.summary = "An open-source SDK for interacting with Uber's public API."
  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.homepage = "https://code.uberinternal.com/diffusion/MONETW/"
  s.authors = { 'Uber API' => 'uber-api-support@uber.com' }
  s.source = { :git => "https://github.com/uber/UberSDK-iOS.git", :tag => "v#{s.version.to_s}" }
  s.requires_arc = true

  s.ios.deployment_target = "7.0"

  s.frameworks  = "Foundation"

  s.subspec "Core" do |sp|
    sp.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*.{h,m}"
    sp.ios.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/iOS/*.{h,m}"
    sp.dependency 'Mantle', '1.4.1'
    # sp.private_header_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*+Internal.h"
    # sp.resource_bundle = {
    #   'UberSDK' => ["#{s.name}/#{s.name}/#{sp.base_name}/Resources/*.{h,m}"]
    # }
  end

  s.subspec "API" do |sp|
    sp.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*.{h,m}"
    # sp.private_header_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*+Internal.h"
  end

  s.subspec "OAuth2" do |sp|
    sp.dependency 'UberSDK/Core'

    sp.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*.{h,m}"
    sp.ios.source_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/iOS/*.{h,m}"
    # sp.private_header_files = "#{s.name}/#{s.name}/#{sp.base_name}/Classes/*+Internal.h"
  end
end
