Gem::Specification.new do |s|
  s.name        = 'atomic_cms'
  s.version     = '0.3.0'
  s.summary     = 'Atomic CMS'
  s.description = 'Live CMS powered by atomic assets.'
  s.authors     = ['Don Humphreys', 'Spartan']
  s.email       = 'spartan-helot@spartansystems.co'
  s.files       = `git ls-files`.split(/\n/)
  s.test_files  = Dir['spec/**/*']
  s.homepage    = 'https://github.com/spartansystems/atomic_cms'
  s.license     = 'MIT'

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'activeadmin', '1.0.0.pre2'
  s.add_dependency 'atomic_assets', '~> 0.1.0'
  s.add_dependency 'jquery-rails', '~> 4.0', '>= 4.0.3'
  s.add_dependency 'redcarpet', '~> 3.3'
  s.add_dependency 'slim-rails', '~> 3.0'
  s.add_dependency 'paperclip', '~> 4.3'

  s.add_development_dependency 'rspec-core', '~> 3.3'
  s.add_development_dependency 'rspec-expectations', '~> 3.3'
  s.add_development_dependency 'rspec-mocks', '~> 3.3'
  s.add_development_dependency 'rspec-support', '~> 3.3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'sqlite3'
end
