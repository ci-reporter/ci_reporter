# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.expand_path('../utils', __FILE__)

namespace :ci do
  namespace :setup do
    task :spec_report_cleanup do
      rm_rf ENV["CI_REPORTS"] || "spec/reports"
    end

    task :rspec => :spec_report_cleanup do
      spec_opts = ["--require", CI::Reporter.maybe_quote_filename("#{File.dirname(__FILE__)}/rspec_loader.rb"),
        "--format", "CI::Reporter::RSpec"].join(" ")
      ENV["SPEC_OPTS"] = "#{ENV['SPEC_OPTS']} #{spec_opts}"
    end

    task :rspecdoc => :spec_report_cleanup do
      spec_opts = ["--require", CI::Reporter.maybe_quote_filename("#{File.dirname(__FILE__)}/rspec_loader.rb"),
        "--format", "CI::Reporter::RSpecDoc"].join(" ")
      ENV["SPEC_OPTS"] = "#{ENV['SPEC_OPTS']} #{spec_opts}"
    end

    task :rspecbase => :spec_report_cleanup do
      spec_opts = ["--require", CI::Reporter.maybe_quote_filename("#{File.dirname(__FILE__)}/rspec_loader.rb"),
        "--format", "CI::Reporter::RSpecBase"].join(" ")
      ENV["SPEC_OPTS"] = "#{ENV['SPEC_OPTS']} #{spec_opts}"
    end
  end
end
