namespace :ci do
  namespace :setup do
    task :testunit do
      rm_rf ENV["CI_REPORTS"] || "test/reports"
      ENV["TESTOPTS"] = "#{File.dirname(__FILE__)}/test_unit_loader.rb"
    end
  end
end
