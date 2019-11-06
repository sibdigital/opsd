$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../../lib", __dir__)

# Maintain your gem's version:
require "open_project/reporting2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openproject-reporting2"
  s.version     = OpenProject::Reporting2::VERSION
  s.authors     = "OpenProject GmbH"
  s.email       = "info@openproject.com"
  s.homepage    = "https://community.openproject.org/projects/plugin-reporting"
  s.summary     = "OpenProject Reporting2"
  s.description = "This plugin allows creating custom target reports with filtering and grouping created by the OpenProject Targets plugin"

  s.files       = Dir["{app,config,db,lib}/**/*", "README.md"]

  s.add_dependency "reporting_engine", ">= 1.1.0"
  # s.add_dependency "openproject-costs", "= #{OpenProject::Reporting2::VERSION}"

  s.add_dependency 'jquery-tablesorter', '~> 1.25.5'

  s.add_development_dependency "factory_girl_rails", "~> 4.0"
end
