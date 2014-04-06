# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ci_reporter"
  s.version = "1.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = "2014-04-06"
  s.description = "CI::Reporter is an add-on to Test::Unit, RSpec and Cucumber that allows you to generate XML reports of your test, spec and/or feature runs. The resulting files can be read by a continuous integration system that understands Ant's JUnit report XML format, thus allowing your CI system to track test/spec successes and failures."
  s.email = "nick@nicksieger.com"
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc"]
  s.files = [".gemtest", ".hoerc", ".rspec", ".travis.before_install.sh", ".travis.yml", "Gemfile", "History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc", "Rakefile", "acceptance/cucumber/cucumber_example.feature", "acceptance/cucumber/step_definitions/development_steps.rb", "acceptance/minitest_example_test.rb", "acceptance/rspec_example_spec.rb", "acceptance/spinach/features/spinach_example.feature", "acceptance/spinach/features/steps/example_spinach_feature.rb", "acceptance/test_unit_example_test.rb", "acceptance/verification_spec.rb", "ci_reporter.gemspec", "lib/ci/reporter/core.rb", "lib/ci/reporter/cucumber.rb", "lib/ci/reporter/minitest.rb", "lib/ci/reporter/rake/cucumber.rb", "lib/ci/reporter/rake/cucumber_loader.rb", "lib/ci/reporter/rake/minitest.rb", "lib/ci/reporter/rake/minitest_loader.rb", "lib/ci/reporter/rake/rspec.rb", "lib/ci/reporter/rake/rspec_loader.rb", "lib/ci/reporter/rake/spinach.rb", "lib/ci/reporter/rake/spinach_loader.rb", "lib/ci/reporter/rake/test_unit.rb", "lib/ci/reporter/rake/test_unit_loader.rb", "lib/ci/reporter/rake/utils.rb", "lib/ci/reporter/report_manager.rb", "lib/ci/reporter/rspec.rb", "lib/ci/reporter/spinach.rb", "lib/ci/reporter/test_suite.rb", "lib/ci/reporter/test_unit.rb", "lib/ci/reporter/version.rb", "spec/ci/reporter/cucumber_spec.rb", "spec/ci/reporter/output_capture_spec.rb", "spec/ci/reporter/rake/rake_tasks_spec.rb", "spec/ci/reporter/report_manager_spec.rb", "spec/ci/reporter/rspec_spec.rb", "spec/ci/reporter/test_suite_spec.rb", "spec/ci/reporter/test_unit_spec.rb", "spec/spec_helper.rb", "stub.rake", "tasks/ci_reporter.rake"]
  s.homepage = "https://github.com/nicksieger/ci_reporter"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc", "-SHN", "-f", "darkfish"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "CI::Reporter allows you to generate reams of XML for use with continuous integration systems."
  s.test_files = ["spec/ci/reporter/cucumber_spec.rb", "spec/ci/reporter/output_capture_spec.rb", "spec/ci/reporter/rake/rake_tasks_spec.rb", "spec/ci/reporter/report_manager_spec.rb", "spec/ci/reporter/rspec_spec.rb", "spec/ci/reporter/test_suite_spec.rb", "spec/ci/reporter/test_unit_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe-git>, ["~> 1.5.0"])
      s.add_development_dependency(%q<cucumber>, [">= 1.3.3"])
      s.add_development_dependency(%q<rspec>, ["> 2.0.0"])
      s.add_development_dependency(%q<test-unit>, ["> 2.4.9"])
      s.add_development_dependency(%q<minitest>, ["~> 2.2.0"])
      s.add_development_dependency(%q<spinach>, [">= 0.8.7"])
      s.add_development_dependency(%q<hoe>, ["~> 3.7"])
    else
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe-git>, ["~> 1.5.0"])
      s.add_dependency(%q<cucumber>, [">= 1.3.3"])
      s.add_dependency(%q<rspec>, ["> 2.0.0"])
      s.add_dependency(%q<test-unit>, ["> 2.4.9"])
      s.add_dependency(%q<minitest>, ["~> 2.2.0"])
      s.add_dependency(%q<spinach>, [">= 0.8.7"])
      s.add_dependency(%q<hoe>, ["~> 3.7"])
    end
  else
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe-git>, ["~> 1.5.0"])
    s.add_dependency(%q<cucumber>, [">= 1.3.3"])
    s.add_dependency(%q<rspec>, ["> 2.0.0"])
    s.add_dependency(%q<test-unit>, ["> 2.4.9"])
    s.add_dependency(%q<minitest>, ["~> 2.2.0"])
    s.add_dependency(%q<spinach>, [">= 0.8.7"])
    s.add_dependency(%q<hoe>, ["~> 3.7"])
  end
end
