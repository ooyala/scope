Gem::Specification.new do |s|
  s.name = "scope"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">=0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 2 if s.respond_to? :specification_version=

  s.author = "Phil Crosby"
  s.email = "phil.crosby@gmail.com"

  s.description = ""
  s.summary = ""
  s.homepage = "http://github.com/ooyala/scope"
  s.rubyforge_project = "scope"

  s.files = %w(
    scope.gemspec
    lib/scope.rb
  )
  s.add_dependency("mini-test")
end