
Pod::Spec.new do |s|
  s.name         = "RNDatamiSdk"
  s.version      = "1.0.0"
  s.summary      = "RNDatamiSdk"
  s.description  = <<-DESC
                  RNDatamiSdk
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNDatamiSdk.git", :tag => "master" }
  s.source_files  = "RNDatamiSdk/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"
  s.dependency 'SmiSdk', :git => 'https://bitbucket.org/datami/ios-podspec.git'

end

  