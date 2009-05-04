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
      def initialize(*args, &block)
        super
        @report_manager = ReportManager.new("cucumber")
        @current_suite  = nil
        @current_test   = nil
      end

      def visit_feature_name(name)
        @feature_name = name.split("\n").first
        super
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        start_scenario("#{@feature_name}-#{name}")
        super
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        start_scenario(step_match) unless status == :outline
        super
      end

      private
      def start_scenario(suite_name)
        finish_scenario unless @current_suite.nil?
        @current_suite = TestSuite.new(suite_name)
        @current_suite.start
      end

      def finish_scenario
        finish_example unless @current_test.nil?
        unless @current_suite.nil?
          @current_suite.finish
          # puts @current_suite.inspect
          @report_manager.write_report(@current_suite)
          @current_suite = nil
        end
      end

      def start_example(test_name)
        finish_example unless @current_test.nil?
        @current_test = TestCase.new(test_name)
        @current_test.start
        puts @current_test.inspect
      end

      def finish_example
        unless @current_test.nil?
          @current_test.finish
          @current_suite.testcases << @current_test
          @current_test = nil
        end
      end
    end

    class CucumberDoc < ::Cucumber::Formatter::Pretty
    end
  end
end
