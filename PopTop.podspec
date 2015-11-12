Pod::Spec.new do |s|
  s.name         = 'PopTop'
  s.version      = '0.0.5'
  s.summary      = 'A simple way to return canned responses'
  s.homepage     = 'https://github.com/bellycard/poptop'
  s.license      = 'MIT'
  s.author       = { 'AJ Self': 'aj.self3@gmail.com' }
  s.platform     = :ios, '8.0'

  s.source       = { git: 'https://github.com/bellycard/PopTop.git', tag: '0.0.5' }

  s.source_files  = 'Source/*.swift'

end
