Pod::Spec.new do |s|
  s.name         = "CNLUIKitTools"
  s.version      = "0.0.17"
  s.summary      = "Common extensions to UIKit"
  s.description  = <<-DESC
Common extensions to UIKit. Commonly used in other Comlex Numbers projects.
                   DESC
  s.homepage     = "https://github.com/megavolt605/CNLUIKitTools"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Igor Smirnov" => "megavolt605@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/megavolt605/CNLUIKitTools.git", :tag => "#{s.version}" }
  s.source_files  = "CNLUIKitTools/**/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"
  s.framework  = "Foundation", "UIKit", "CoreLocation""
  s.dependency "CNLFoundationTools" # , "~> 1.4"
end
