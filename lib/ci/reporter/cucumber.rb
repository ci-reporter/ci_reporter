# (c) Copyright 2006-2009 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'ci/reporter/core'
tried_gem = false
begin
  require 'cucumber'
  require 'cucumber/formatter/progress'
  require 'cucumber/formatter/pretty'
rescue LoadError
  unless tried_gem
    tried_gem = true
    require 'rubygems'
    gem 'cucumber'
    retry
  end
end

module CI
  module Reporter
    class Cucumber < ::Cucumber::Formatter::Progress
    end

    class CucumberDoc < ::Cucumber::Formatter::Pretty
    end
  end
end
