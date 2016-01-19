Pod::Spec.new do |s|
  s.name         = 'PopTop'
  s.version      = '0.0.9'
  s.summary      = 'A simple way to return canned responses'
  s.homepage     = 'https://github.com/bellycard/PopTop'

  s.license      = { type: 'MIT', text: <<-LICENSE
    This license text is required or else CocoaPods gets upset.
    LICENSE
  }

  s.author       = { 'AJ Self': 'aj.self3@gmail.com' }
  s.platform     = :ios, '8.0'

  s.source       = { git: 'https://github.com/bellycard/PopTop.git', tag: s.version.to_s }

  s.dependency 'SwiftyJSON', '~> 2.3'

  s.source_files  = 'Source/*.swift'

end
