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

      attr_accessor :test_suite, :report_manager, :feature_name

      def initialize(*args, &block)
        self.report_manager = ReportManager.new("cucumber")
        super
      end

      def visit_feature_name(name)
        self.feature_name = name.split("\n").first
        super
      end

      def visit_feature_element(feature_element)
        self.test_suite = TestSuite.new("#{feature_name} #{feature_element.instance_variable_get("@name")}")
        test_suite.start

        return_value = super

        test_suite.finish
        report_manager.write_report(test_suite)
        self.test_suite = nil

        return_value
      end

      def visit_step(step)
        test_case = TestCase.new(step.name)
        test_case.start

        return_value = super

        test_case.finish
        test_suite.testcases << test_case

        return_value
      end
    end

    class CucumberDoc < ::Cucumber::Formatter::Pretty
    end
  end
end
