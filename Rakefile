require 'spec/rake/spectask'

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/#{ENV['SPECS']}"]
end
