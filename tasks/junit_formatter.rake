SPEC_OPTS = []
namespace :spec do
  task :setupxml do
    rm_rf "spec/reports"
    ENV['RSPECOPTS'] = ["--require", "#{File.dirname(__FILE__)}/../lib/rspec_junit_report_formatter", 
      "--format", "RSpec::JUnitReportFormatter"].join(" ")
  end
end
