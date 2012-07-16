#require File.expand_path('../utils', __FILE__)

namespace :ci do
  namespace :setup do
    task :spinach_report_cleanup do
      rm_rf ENV["CI_REPORTS"] || "features/reports"
    end

    task :spinach => :spinach_report_cleanup do
      # ???
    end
  end
end
