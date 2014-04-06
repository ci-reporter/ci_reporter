#--
# Copyright (c) 2006-2014 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require 'bundler/setup'

begin
  require 'hoe'
  Hoe.plugin :git
  require File.dirname(__FILE__) + '/lib/ci/reporter/version'
  hoe = Hoe.spec("ci_reporter") do |p|
    p.version = CI::Reporter::VERSION
    p.group_name = "caldersphere"
    p.readme_file = "README.rdoc"
    p.urls = ["https://github.com/nicksieger/ci_reporter"]
    p.author = "Nick Sieger"
    p.email = "nick@nicksieger.com"
    p.readme_file = 'README.rdoc'
    p.summary = "CI::Reporter allows you to generate reams of XML for use with continuous integration systems."
    p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
    p.description = p.paragraphs_of('README.rdoc', 0...1).join("\n\n")
    p.extra_rdoc_files += ["README.rdoc"]
    p.test_globs = ["spec/**/*_spec.rb"]
    p.extra_deps     << [ 'builder',   '>= 2.1.2'  ]
    p.extra_dev_deps << [ 'hoe-git',   '~> 1.5.0'  ]
    p.extra_dev_deps << [ 'cucumber',  '>= 1.3.3'  ]
    p.extra_dev_deps << [ 'rspec',     '> 2.0.0'   ]
    p.extra_dev_deps << [ 'test-unit', '> 2.4.9'   ]
    p.extra_dev_deps << [ 'minitest',  '~> 2.2.0'  ]
    p.extra_dev_deps << [ 'spinach',   '>= 0.8.7'  ]
    p.clean_globs += ["spec/reports", "acceptance/reports"]
    p.license 'MIT'
  end
  hoe.spec.rdoc_options += ["-SHN", "-f", "darkfish"]

  task :gemspec do
    File.open("#{hoe.name}.gemspec", "w") {|f| f << hoe.spec.to_ruby }
  end
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end

def run_ruby_acceptance(cmd)
  ENV['CI_REPORTS'] ||= "acceptance/reports"
  if ENV['RUBYOPT']
    opts = ENV['RUBYOPT']
    ENV['RUBYOPT'] = nil
  else
    opts = "-rubygems"
  end
  begin
    result_proc = proc {|ok,*| puts "Failures above are expected." unless ok }
    ruby "-Ilib #{opts} #{cmd}", &result_proc
  ensure
    ENV['RUBYOPT'] = opts if opts != "-rubygems"
    ENV.delete 'CI_REPORTS'
  end
end


namespace :generate do
  task :test_unit do
    run_ruby_acceptance "-rci/reporter/rake/test_unit_loader acceptance/test_unit_example_test.rb"
  end

  task :minitest do
    run_ruby_acceptance "-rci/reporter/rake/minitest_loader acceptance/minitest_example_test.rb"
  end

  task :rspec do
    rspec = "#{Gem.loaded_specs['rspec-core'].gem_dir}/exe/rspec"
    run_ruby_acceptance "-S #{rspec} --require ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec acceptance/rspec_example_spec.rb"
  end

  task :cucumber do
    cucumber = "#{Gem.loaded_specs['cucumber'].gem_dir}/bin/cucumber"
    run_ruby_acceptance "-rci/reporter/rake/cucumber_loader -S #{cucumber} --format CI::Reporter::Cucumber acceptance/cucumber"
  end

  task :spinach do
    spinach = "#{Gem.loaded_specs['spinach'].gem_dir}/bin/spinach"
    run_ruby_acceptance "-I../../lib -rci/reporter/rake/spinach_loader -S #{spinach} -r ci_reporter -f acceptance/spinach/features"
  end

  task :clean do
    rm_rf "acceptance/reports"
  end

  task :all => [:clean, :test_unit, :minitest, :rspec, :cucumber, :spinach]
end

task :acceptance => "generate:all"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:acceptance_spec) do |t|
  t.pattern = FileList['acceptance/verification_spec.rb']
  t.rspec_opts = "--color"
end
task :acceptance => :acceptance_spec

task :default => :acceptance
