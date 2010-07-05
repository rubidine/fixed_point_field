Gem::Specification.new do |s|
  s.name = "fixed_point_field"
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Todd Willey <todd@rubidine.com>"]
  s.date = "2010-07-05"
  s.description = "Store numeric amounts with a known number of decial points, such as currency, as a whole number, for more precise (non-floating point) operations."
  s.email = "powerup@rubidine.com"
  s.extra_rdoc_files = ["README"]
  s.files = [
    "README",
    "Rakefile",
    "init.rb",
    "lib/fixed_point_field.rb",
    "tasks/fixed_point_field_tasks.rake",
    "test/fixed_point_field_test.rb"
  ]
  s.homepage = "http://github.com/rubidine/fixed_point_field"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.5"
  s.summary = "ActiveRecord plugin for dealing with currency"
  s.test_files = ["test/fixed_point_field_test.rb"]
end
