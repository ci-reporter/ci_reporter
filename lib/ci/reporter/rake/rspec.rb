namespace :ci do
  namespace :setup do
    task :rspec do
      rm_rf ENV["CI_REPORTS"] || "spec/reports"
      ENV["RSPECOPTS"] = ["--require", "#{File.dirname(__FILE__)}/rspec_loader.rb", 
        "--format", "CI::Reporter::RSpec"].join(" ")
    end
  end
end
