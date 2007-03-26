require 'spec/rake/spectask'
require 'hoe'

MANIFEST = FileList["History.txt", "Manifest.txt", "README.txt", "LICENSE.txt", "Rakefile",
  "lib/**/*.rb", "spec/**/*.rb", "tasks/**/*.rake"]

Hoe.new("ci_reporter", "1.3") do |p|
  p.rubyforge_name = "caldersphere"
  p.url = "http://caldersphere.rubyforge.org/ci_reporter"
  p.author = "Nick Sieger"
  p.email = "nick@nicksieger.com"
  p.summary = "CI::Reporter allows you to generate reams of XML for use with continuous integration systems."
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.description = p.paragraphs_of('README.txt', 0...1).join("\n\n")
  p.extra_deps.reject!{|d| d.first == "hoe"}
  p.test_globs = ["spec/**/*_spec.rb"]
end.spec.files = MANIFEST

# Hoe insists on setting task :default => :test
# !@#$ no easy way to empty the default list of prerequisites
Rake::Task['default'].send :instance_variable_set, "@prerequisites", FileList[]

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--diff", "unified"]
end

# Automated manifest
task :manifest do
  File.open("Manifest.txt", "w") {|f| MANIFEST.each {|n| f << "#{n}\n"} }
end

task :package => :manifest