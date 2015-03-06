Gem::Specification.new do |s|
  s.name        = 'msfl'
  s.version     = '0.0.1-dev'
  s.date        = '2015-03-05'
  s.summary     = "MSFL in Ruby"
  s.description = "Serializers, validators, and other tasty goodness for the Mattermark Semantic Filter Language in Ruby."
  s.authors     = ["Courtland Caldwell"]
  s.email       = 'courtland@mattermark.com'
  s.files       = [
      "lib/msfl.rb",
  ]
  s.homepage    =
      'https://github.com/caldwecr/msfl'
  #s.add_runtime_dependency
  s.add_development_dependency "rake"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec"
  s.add_development_dependency "byebug"
  s.license     = "MIT"
end