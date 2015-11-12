Pod::Spec.new do |s|
  s.name         = 'PopTop'
  s.version      = '0.0.6'
  s.summary      = 'A simple way to return canned responses'
  s.homepage     = 'https://www.bellycard.com'  
  
  s.license      = { type: 'MIT', text: <<-LICENSE
    This license text is required or else CocoaPods gets upset.
    LICENSE
  }

  s.author       = { 'AJ Self': 'aj.self3@gmail.com' }
  s.platform     = :ios, '8.0'

  s.source       = { git: 'https://02e34411c57bedacd7b5e66d60efaa3b9ffbc346@github.com/bellycard/PopTop.git', tag: '0.0.6' }
  
  s.dependency 'SwiftyJSON', '~> 2.3'

  s.source_files  = 'Source/*.swift'

end
