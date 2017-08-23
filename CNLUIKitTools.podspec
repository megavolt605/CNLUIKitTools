Pod::Spec.new do |s|
  s.name         = "CNLUIKitTools"
  s.version      = "0.0.18"
  s.summary      = "Common extensions to UIKit"
  s.description  = <<-DESC
Common extensions to UIKit. Commonly used in other Comlex Numbers projects.
                   DESC
  s.homepage     = "https://github.com/megavolt605/#{s.name}"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Igor Smirnov" => "megavolt605@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/megavolt605/#{s.name}.git", :tag => "#{s.version}" }
  s.source_files  = "#{s.name}/**/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"
  s.framework  = "Foundation", "UIKit", "CoreLocation"
  s.dependency "CNLFoundationTools" # , "~> 1.4"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
