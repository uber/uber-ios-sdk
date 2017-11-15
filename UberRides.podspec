require_relative("PodspecShared")

Pod::Spec.new do |s|
  configure_podspec(s, "UberRides")
  s.dependency "UberCore"
end