# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ci_reporter"
  s.version = "1.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = "2012-10-09"
  s.description = "CI::Reporter is an add-on to Test::Unit, RSpec and Cucumber that allows you to generate XML reports of your test, spec and/or feature runs. The resulting files can be read by a continuous integration system that understands Ant's JUnit report XML format, thus allowing your CI system to track test/spec successes and failures."
  s.email = "nick@nicksieger.com"
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc"]
  s.files = [".travis.yml", "Gemfile", "Gemfile.lock", "History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc", "Rakefile", "acceptance/cucumber/cucumber_example.feature", "acceptance/cucumber/step_definitions/development_steps.rb", "acceptance/minitest_example_test.rb", "acceptance/rspec_example_spec.rb", "acceptance/test_unit_example_test.rb", "acceptance/verification_spec.rb", "ci_reporter.gemspec", "lib/ci/reporter/core.rb", "lib/ci/reporter/cucumber.rb", "lib/ci/reporter/minitest.rb", "lib/ci/reporter/rake/cucumber.rb", "lib/ci/reporter/rake/cucumber_loader.rb", "lib/ci/reporter/rake/minitest.rb", "lib/ci/reporter/rake/minitest_loader.rb", "lib/ci/reporter/rake/rspec.rb", "lib/ci/reporter/rake/rspec_loader.rb", "lib/ci/reporter/rake/test_unit.rb", "lib/ci/reporter/rake/test_unit_loader.rb", "lib/ci/reporter/rake/utils.rb", "lib/ci/reporter/report_manager.rb", "lib/ci/reporter/rspec.rb", "lib/ci/reporter/test_suite.rb", "lib/ci/reporter/test_unit.rb", "lib/ci/reporter/version.rb", "spec/ci/reporter/cucumber_spec.rb", "spec/ci/reporter/output_capture_spec.rb", "spec/ci/reporter/rake/rake_tasks_spec.rb", "spec/ci/reporter/report_manager_spec.rb", "spec/ci/reporter/rspec_spec.rb", "spec/ci/reporter/test_suite_spec.rb", "spec/ci/reporter/test_unit_spec.rb", "spec/spec_helper.rb", "stub.rake", "tasks/ci_reporter.rake", ".gemtest"]
  s.homepage = "http://caldersphere.rubyforge.org/ci_reporter"
  s.rdoc_options = ["--main", "README.rdoc", "-SHN", "-f", "darkfish"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "caldersphere"
  s.rubygems_version = "1.8.24"
  s.summary = "CI::Reporter allows you to generate reams of XML for use with continuous integration systems."
  s.test_files = ["spec/ci/reporter/cucumber_spec.rb", "spec/ci/reporter/output_capture_spec.rb", "spec/ci/reporter/rake/rake_tasks_spec.rb", "spec/ci/reporter/report_manager_spec.rb", "spec/ci/reporter/rspec_spec.rb", "spec/ci/reporter/test_suite_spec.rb", "spec/ci/reporter/test_unit_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
    else
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, ["~> 2.12"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
    end
  else
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, ["~> 2.12"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
  end
end
