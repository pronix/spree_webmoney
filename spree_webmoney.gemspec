Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_webmoney'
  s.version     = '0.0.1'
  s.summary     = 'Add gem summary here'
  s.description = 'Add webmoney support for spree'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'tradefast.ru'
  s.email             = 'pronix.service@gmail.com'
  s.homepage          = 'http://tradefast.ru'
  # s.rubyforge_project = 'actionmailer'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.1')
end
