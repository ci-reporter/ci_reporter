#--
# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require 'bundler/setup'

MANIFEST = FileList["History.txt", "Manifest.txt", "README.rdoc", "LICENSE.txt", "Rakefile",
  "*.rake", "lib/**/*.rb", "spec/**/*.rb", "tasks/**/*.rake"]

begin
  File.open("Manifest.txt", "w") {|f| MANIFEST.sort.each {|n| f << "#{n}\n"} }
  require 'hoe'
  Hoe.plugin :rubyforge
  require File.dirname(__FILE__) + '/lib/ci/reporter/version'
  hoe = Hoe.spec("ci_reporter") do |p|
    p.version = CI::Reporter::VERSION
    p.rubyforge_name = "caldersphere"
    p.readme_file = "README.rdoc"
    p.url = "http://caldersphere.rubyforge.org/ci_reporter"
    p.author = "Nick Sieger"
    p.email = "nick@nicksieger.com"
    p.readme_file = 'README.rdoc'
    p.summary = "CI::Reporter allows you to generate reams of XML for use with continuous integration systems."
    p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
    p.description = p.paragraphs_of('README.rdoc', 0...1).join("\n\n")
    p.extra_rdoc_files += ["README.rdoc"]
    p.test_globs = ["spec/**/*_spec.rb"]
    p.extra_deps << ['builder', ">= 2.1.2"]
  end
  hoe.spec.files = MANIFEST
  hoe.spec.rdoc_options += ["-SHN", "-f", "darkfish"]

  task :gemspec do
    File.open("#{hoe.name}.gemspec", "w") {|f| f << hoe.spec.to_ruby }
  end
  task :package => :gemspec
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end

# Hoe insists on setting task :default => :test
# !@#$ no easy way to empty the default list of prerequisites
# Leave my tasks alone, Hoe
%w(default spec rcov).each do |task|
  next unless Rake::Task.task_defined?(task)
  Rake::Task[task].prerequisites.clear
  Rake::Task[task].actions.clear
end

# RCov only on 1.8
if defined?(RUBY_ENGINE)
  task :default => :spec
else
  task :default => :rcov
end

RSpecTask = begin
  require 'rspec/core/rake_task'
  @spec_bin = 'rspec'
  RSpec::Core::RakeTask
rescue LoadError
  require 'spec/rake/spectask'
  @spec_bin = 'spec'
  Spec::Rake::SpecTask
end

RSpecTask.new do |t|
end

RSpecTask.new("spec:rcov") do |t|
  t.rcov_opts = ['--exclude gems/*']
  t.rcov = true
end

begin
  require 'spec/rake/verify_rcov'
  # so we don't confuse autotest
  RCov::VerifyTask.new(:rcov) do |t|
    # Can't get threshold up to 100 unless RSpec backwards compatibility
    # code is dropped
    t.threshold = 95
    t.require_exact_threshold = false
  end
rescue LoadError
end

task :rcov => "spec:rcov"

task :generate_output do
  rm_rf "acceptance/reports"
  ENV['CI_REPORTS'] = "acceptance/reports"
  if ENV['RUBYOPT']
    opts = ENV['RUBYOPT']
    ENV['RUBYOPT'] = nil
  else
    opts = "-rubygems"
  end
  begin
    result_proc = proc {|ok,*| puts "Failures above are expected." unless ok }
    ruby "-Ilib #{opts} -rci/reporter/rake/test_unit_loader acceptance/test_unit_example_test.rb", &result_proc
    ruby "-Ilib #{opts} -rci/reporter/rake/minitest_loader acceptance/minitest_example_test.rb", &result_proc
    ruby "-Ilib #{opts} -S #{@spec_bin} --require ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec acceptance/rspec_example_spec.rb", &result_proc
    ruby "-Ilib #{opts} -rci/reporter/rake/cucumber_loader -S cucumber --format CI::Reporter::Cucumber acceptance/cucumber", &result_proc
  ensure
    ENV['RUBYOPT'] = opts if opts != "-rubygems"
    ENV.delete 'CI_REPORTS'
  end
end
task :acceptance => :generate_output

RSpecTask.new(:acceptance_spec) do |t|
  t.pattern = FileList['acceptance/verification_spec.rb']
end
task :acceptance => :acceptance_spec

task :default => :acceptance
