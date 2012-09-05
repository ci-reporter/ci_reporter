# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'ci/reporter/core'
require 'cucumber'
begin
  require 'cucumber/ast/visitor'
rescue LoadError
end

module CI
  module Reporter
    class CucumberFailure
      attr_reader :step

      def initialize(step)
        @step = step
      end

      def failure?
        true
      end

      def error?
        !failure?
      end

      def name
        step.exception.class.name
      end

      def message
        step.exception.message
      end

      def location
        step.exception.backtrace.join("\n")
      end
    end

    class Cucumber
      attr_accessor :report_manager, :test_suite, :name

      def initialize(step_mother, io, options)
        @report_manager = ReportManager.new("features")
      end

      def before_feature(feature)
        self.test_suite = TestSuite.new(@name)
        test_suite.start
      end

      def after_feature(feature)
        test_suite.name = @name
        test_suite.finish
        report_manager.write_report(@test_suite)
        @test_suite = nil
      end

      def before_background(*args)
      end

      def after_background(*args)
      end

      def feature_name(keyword, name)
        @name = (name || "Unnamed feature").split("\n").first
      end

      def scenario_name(keyword, name, *args)
        @scenario = (name || "Unnamed scenario").split("\n").first
      end

      def before_steps(steps)
        @test_case = TestCase.new(@scenario)
        @test_case.start
      end

      def after_steps(steps)
        @test_case.finish

        case steps.status
        when :pending, :undefined
          @test_case.name = "#{@test_case.name} (PENDING)"
        when :skipped
          @test_case.name = "#{@test_case.name} (SKIPPED)"
        when :failed
          @test_case.failures << CucumberFailure.new(steps)
        end

        test_suite.testcases << @test_case
        @test_case = nil
      end

      def before_examples(*args)
        @header_row = true
      end

      def after_examples(*args)
      end

      def before_table_row(table_row)
        row = table_row # shorthand for table_row
        # check multiple versions of the row and try to find the best fit
        outline = (row.respond_to? :name)             ? row.name :
                  (row.respond_to? :scenario_outline) ? row.scenario_outline :
                                                        row.to_s
        @test_case = TestCase.new("#@scenario (outline: #{outline})")
        @test_case.start
      end

      def after_table_row(table_row)
        if @header_row
          @header_row = false
          return
        end
        @test_case.finish
        if table_row.respond_to? :failed?
          @test_case.failures << CucumberFailure.new(table_row) if table_row.failed?
          test_suite.testcases << @test_case
          @test_case = nil
        end
      end
    end
  end
end
