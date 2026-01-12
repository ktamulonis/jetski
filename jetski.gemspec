require_relative "./lib/jetski/version"

Gem::Specification.new do |s|
  s.name        = "jetski"
  s.version     = Jetski::VERSION
  s.summary     = "A simple and fast MVC framework"
  s.description = "Would you rather ride on a train or a jetski? that is the question you might use when comparing using our framework or the popular Ruby on Rails framework. "
  s.authors     = ["Indigo Tech Tutorials"]
  s.email       = "indigo@tech.tut"
  s.files       = [
                    Dir.glob("bin/**/*"), 
                    Dir.glob("lib/**/*"),
                    Dir.glob("templates/**/*"),
                  ].flatten
  s.homepage    = "https://rubygems.org/gems/jetski"
  s.license       = "MIT"
  s.metadata['source_code_uri'] = 'https://github.com/indigotechtutorials/jetski'
  s.add_dependency('webrick', '~> 1.9.1')
  s.add_dependency('thor', '~> 1.4.0')
  s.add_dependency('erb', '~> 5.1.2')
  s.add_dependency('ostruct', '~> 0.6.2')
  s.add_dependency('sqlite3', '~> 2.8.0')
  s.add_dependency('pry', '~> 0.15.2')
  s.add_dependency('rack', '~> 3.2.4')
  s.add_development_dependency "minitest"
  s.add_dependency('kinship', '~> 0.0.1')
  s.executables << "jetski"
end
