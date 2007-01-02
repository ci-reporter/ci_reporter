SPEC_OPTS = []
namespace :spec do
  task :setupxml do
    SPEC_OPTS << ["--require", "#{File.dirname(__FILE__)}/../lib/rspec_junit_report_formatter", "--format", "RSpec::JUnitReportFormatter"]
    SPEC_OPTS.flatten!
  end
end
