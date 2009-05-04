# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

namespace :ci do
  namespace :setup do
    task :cucumber_report_cleanup do
      rm_rf ENV["CI_REPORTS"] || "features/reports"
    end

    task :cucumber => :cucumber_report_cleanup do
      spec_opts = ["--require", "#{File.dirname(__FILE__)}/cucumber_loader.rb",
        "--format", "CI::Reporter::Cucumber"].join(" ")
      ENV["CUCUMBER_OPTS"] = "#{ENV['CUCUMBER_OPTS']} #{spec_opts}"
    end
  end
end
