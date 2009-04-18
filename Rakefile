require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

MANIFEST = FileList["History.txt", "Manifest.txt", "README.txt", "LICENSE.txt", "Rakefile",
  "*.rake", "lib/**/*.rb", "spec/**/*.rb", "tasks/**/*.rake"]

begin
  File.open("Manifest.txt", "w") {|f| MANIFEST.each {|n| f << "#{n}\n"} }
  require 'hoe'
  require File.dirname(__FILE__) + '/lib/ci/reporter/version'
  hoe = Hoe.new("ci_reporter", CI::Reporter::VERSION) do |p|
    p.rubyforge_name = "caldersphere"
    p.url = "http://caldersphere.rubyforge.org/ci_reporter"
    p.author = "Nick Sieger"
    p.email = "nick@nicksieger.com"
    p.summary = "CI::Reporter allows you to generate reams of XML for use with continuous integration systems."
    p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
    p.description = p.paragraphs_of('README.txt', 0...1).join("\n\n")
    p.extra_deps.reject!{|d| d.first == "hoe"}
    p.test_globs = ["spec/**/*_spec.rb"]
    p.extra_deps << ['builder', ">= 2.1.2"]
  end
  hoe.spec.files = MANIFEST
  hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" }
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end

# Hoe insists on setting task :default => :test
# !@#$ no easy way to empty the default list of prerequisites
Rake::Task['default'].send :instance_variable_set, "@prerequisites", FileList[]

# No RCov on JRuby at the moment
if RUBY_PLATFORM =~ /java/
  task :default => :spec
else
  task :default => :rcov
end

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--diff", "unified"]
end

Spec::Rake::SpecTask.new("spec:rcov") do |t|
  t.rcov_opts << '--exclude gems/*'
  t.rcov = true
end
# so we don't confuse autotest
RCov::VerifyTask.new(:rcov) do |t|
  # Can't get threshold up to 100 until the RSpec < 1.0 compatibility
  # code is dropped
  t.threshold = 99
  t.require_exact_threshold = false
end
task "spec:rcov" do
  rm_f "Manifest.txt"
end
task :rcov => "spec:rcov"

task :generate_output do
  rm_f "acceptance/reports/*.xml"
  ENV['CI_REPORTS'] = "acceptance/reports"
  begin
    `ruby -Ilib acceptance/test_unit_example_test.rb` rescue nil
    `ruby -Ilib -S spec --require ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec acceptance/rspec_example_spec.rb` rescue nil
  ensure
    ENV.delete 'CI_REPORTS'
  end
end
task :acceptance => :generate_output

Spec::Rake::SpecTask.new(:acceptance_spec) do |t|
  t.spec_files = FileList['acceptance/verification_spec.rb']
end
task :acceptance => :acceptance_spec

task :default => :acceptance
