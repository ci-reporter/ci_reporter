namespace :ci do
  task :setup_rspec do
    rm_rf ENV["CI_REPORTS"] || "spec/reports"
    ENV["RSPECOPTS"] = ["--require", "#{File.dirname(__FILE__)}/rspec_loader.rb", 
      "--format", "CI::Reporter::RSpec"].join(" ")
  end
  
  task :setup_testunit do
    rm_rf ENV["CI_REPORTS"] || "test/reports"
    ENV["TESTOPTS"] = "#{File.dirname(__FILE__)}/test_unit_loader.rb"
  end
end
