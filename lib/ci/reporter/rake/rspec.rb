# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

namespace :ci do
  namespace :setup do
    task :rspec do
      rm_rf ENV["CI_REPORTS"] || "spec/reports"
      ENV["RSPECOPTS"] ||= ""
      ENV["RSPECOPTS"] += [" --require", "#{File.dirname(__FILE__)}/rspec_loader.rb", 
        "--format", "CI::Reporter::RSpec"].join(" ")
    end
  end
end
