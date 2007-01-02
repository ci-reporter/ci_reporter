SPEC_OPTS = []
namespace :spec do
  task :setupxml do
    ENV['RSPECOPTS'] = ["--require", "#{File.dirname(__FILE__)}/../lib/rspec_junit_report_formatter", 
      "--format", "RSpec::JUnitReportFormatter"].join(" ")
  end
end
