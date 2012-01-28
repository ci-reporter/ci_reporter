# Copyright (c) 2012 Alexander Shcherbinin <alexander.shcherbinin@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.expand_path('../utils', __FILE__)

namespace :ci do
  namespace :setup do
    task :minitest do
      rm_rf ENV["CI_REPORTS"] || "test/reports"
      test_loader = CI::Reporter.maybe_quote_filename "#{File.dirname(__FILE__)}/minitest_loader.rb"
      ENV["TESTOPTS"] = "#{ENV["TESTOPTS"]} #{test_loader}"
    end
  end
end
