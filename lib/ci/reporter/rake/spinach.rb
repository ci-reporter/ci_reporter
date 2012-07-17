namespace :ci do
  namespace :setup do
    task :spinach_report_cleanup do
      rm_rf ENV["CI_REPORTS"] || "features/reports"
    end

    task :spinach => :spinach_report_cleanup do
      loader = File.expand_path('prepare_ci_reporter.rb', ENV["SPINACH_SUPPORT_PATH"] || 'features/support')
      if !File.exist? loader
        File.open(loader, 'w') do |f|
          f.puts "require 'ci/reporter/rake/spinach_loader'"
        end
        at_exit do
          File.unlink loader
        end
      end
    end
  end
end
