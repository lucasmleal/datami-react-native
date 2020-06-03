require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "sd-react-native-smisdk-plugin"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  sd-react-native-smisdk-plugin
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-rn-smi-sdk"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-rn-smi-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.ios.preserve_paths      = 'ios/libsmisdk.a'
  s.ios.vendored_libraries  = 'ios/libsmisdk.a'
  s.requires_arc = true

  s.dependency "React"
  # ...
  # s.dependency "..."
end

