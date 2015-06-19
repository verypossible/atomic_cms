Gem::Specification.new do |s|
  s.name        = 'atomic_cms'
  s.version     = '0.0.1'
  s.date        = '2015-06-19'
  s.summary     = 'Atomic CMS'
  s.description = 'Live CMS powered by atomic assets.'
  s.authors     = ['Don Humphreys']
  s.email       = 'dhumphreys88@gmail.com'
  s.files       = ['lib/atomic_cms.rb']
  # s.homepage    = 'http://rubygems.org/gems/atomic_assets'
  # s.license       = 'MIT'

  s.add_dependency 'activeadmin', '~> 1.0'
  s.add_dependency 'activemodel', '~> 4.0'
  s.add_dependency 'activerecord', '~> 4.0'
  s.add_dependency 'angularjs-rails', '~> 1.3', '>= 1.3.15'
  s.add_dependency 'arbre', '~> 1.0', '>= 1.0.2'
  s.add_dependency 'atomic_assets', '~> 0.0.1'
  s.add_dependency 'draper', '~> 2.1'
  s.add_dependency 'jquery-rails', '~> 4.0', '>= 4.0.3'

  s.add_development_dependency 'rspec-core', '~> 3.3'
  s.add_development_dependency 'rspec-expectations', '~> 3.3'
  s.add_development_dependency 'rspec-mocks', '~> 3.3'
  s.add_development_dependency 'rspec-support', '~> 3.3'
end
