Gem::Specification.new do |s|
  s.name        = 'atomic_cms'
  s.version     = '0.0.1'
  s.date        = '2015-06-19'
  s.summary     = 'Atomic CMS'
  s.description = 'Live CMS powered by atomic assets.'
  s.authors     = ['Don Humphreys']
  s.email       = 'dhumphreys88@gmail.com'
  s.files       = `git ls-files lib`.split(/\n/)
  # s.homepage    = 'http://rubygems.org/gems/atomic_cms'
  # s.license       = 'MIT'

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'activeadmin', '1.0.0.pre2'
  s.add_dependency 'angularjs-rails', '~> 1.3', '< 1.4'
  s.add_dependency 'atomic_assets', '~> 0.0.4'
  s.add_dependency 'jquery-rails', '~> 4.0', '>= 4.0.3'
  s.add_dependency 'redcarpet', '~> 3.3'
  s.add_dependency 'slim-rails', '~> 3.0'

  s.add_development_dependency 'rspec-core', '~> 3.3'
  s.add_development_dependency 'rspec-expectations', '~> 3.3'
  s.add_development_dependency 'rspec-mocks', '~> 3.3'
  s.add_development_dependency 'rspec-support', '~> 3.3'
end
