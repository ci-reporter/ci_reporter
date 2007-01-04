namespace :ci do
  task :setup_rspec do
    rm_rf "spec/reports"
    ENV['RSPECOPTS'] = ["--require", "#{File.dirname(__FILE__)}/rspec.rb", 
      "--format", "CI::Reporter::RSpec"].join(" ")
  end
end
