# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

namespace :ci do
  namespace :setup do
    task :rspec do
      rm_rf ENV["CI_REPORTS"] || "spec/reports"

      spec_opts = ["--require", "#{File.dirname(__FILE__)}/rspec_loader.rb", 
        "--format", "CI::Reporter::RSpec"].join(" ")      
      ENV["SPEC_OPTS"] ||= ""
      ENV["SPEC_OPTS"] += spec_opts
      # Pre RSpec 1.0.6
      ENV["RSPECOPTS"] ||= ""
      ENV["RSPECOPTS"] += spec_opts
    end
  end
end
