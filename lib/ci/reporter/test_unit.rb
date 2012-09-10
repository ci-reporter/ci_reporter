# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'ci/reporter/core'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

module CI
  module Reporter
    # Factory for constructing either a CI::Reporter::TestUnitFailure or CI::Reporter::TestUnitError depending on the result
    # of the test.
    class Failure
      CONST_DEFINED_ARITY = Module.method(:const_defined?).arity

      def self.omission_constant?
        if CONST_DEFINED_ARITY == 1 # 1.8.7 varieties
          Test::Unit.const_defined?(:Omission)
        else
          Test::Unit.const_defined?(:Omission, false)
        end
      end

      def self.notification_constant?
        if CONST_DEFINED_ARITY == 1 # 1.8.7 varieties
          Test::Unit.const_defined?(:Notification)
        else
          Test::Unit.const_defined?(:Notification, false)
        end
      end

      def self.new(fault)
        return TestUnitFailure.new(fault) if fault.kind_of?(Test::Unit::Failure)
        return TestUnitSkipped.new(fault) if omission_constant? &&
          (fault.kind_of?(Test::Unit::Omission) || fault.kind_of?(Test::Unit::Pending))
        return TestUnitNotification.new(fault) if notification_constant? &&
          fault.kind_of?(Test::Unit::Notification)
        TestUnitError.new(fault)
      end
    end

    # Wrapper around a <code>Test::Unit</code> error to be used by the test suite to interpret results.
    class TestUnitError
      def initialize(fault) @fault = fault end
      def failure?() false end
      def error?() true end
      def name() @fault.exception.class.name end
      def message() @fault.exception.message end
      def location() @fault.exception.backtrace.join("\n") end
    end

    # Wrapper around a <code>Test::Unit</code> failure to be used by the test suite to interpret results.
    class TestUnitFailure
      def initialize(fault) @fault = fault end
      def failure?() true end
      def error?() false end
      def name() Test::Unit::AssertionFailedError.name end
      def message() @fault.message end
      def location() @fault.location.join("\n") end
    end

    # Wrapper around a <code>Test::Unit</code> 2.0 omission.
    class TestUnitSkipped
      def initialize(fault) @fault = fault end
      def failure?() false end
      def error?() false end
      def name() @fault.class.name end
      def message() @fault.message end
      def location() @fault.location.join("\n") end
    end

    # Wrapper around a <code>Test::Unit</code> 2.0 notification.
    class TestUnitNotification
      def initialize(fault) @fault = fault end
      def failure?() false end
      def error?() false end
      def name() @fault.class.name end
      def message() @fault.message end
      def location() @fault.location.join("\n") end
    end

    # Replacement Mediator that adds listeners to capture the results of the <code>Test::Unit</code> runs.
    class TestUnit < Test::Unit::UI::TestRunnerMediator
      def initialize(suite, report_mgr = nil)
        super(suite)
        @report_manager = report_mgr || ReportManager.new("test")
        add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:started))
        add_listener(Test::Unit::TestCase::STARTED, &method(:test_started))
        add_listener(Test::Unit::TestCase::FINISHED, &method(:test_finished))
        add_listener(Test::Unit::TestResult::FAULT, &method(:fault))
        add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:finished))
      end

      def started(result)
        @suite_result = result
        @last_assertion_count = 0
        @current_suite = nil
        @unknown_count = 0
        @result_assertion_count = 0
      end

      def test_started(name)
        test_name, suite_name = extract_names(name)
        unless @current_suite && @current_suite.name == suite_name
          finish_suite
          start_suite(suite_name)
        end
        start_test(test_name)
      end

      def test_finished(name)
        finish_test
      end

      def fault(fault)
        tc = @current_suite.testcases.last
        tc.failures << Failure.new(fault)
      end

      def finished(elapsed_time)
        finish_suite
      end

      private
      def extract_names(name)
        match = name.match(/(.*)\(([^)]*)\)/)
        if match
          [match[1], match[2]]
        else
          @unknown_count += 1
          [name, "unknown-#{@unknown_count}"]
        end
      end

      def start_suite(suite_name)
        @current_suite = TestSuite.new(suite_name)
        @current_suite.start
      end

      def finish_suite
        if @current_suite
          @current_suite.finish
          @current_suite.assertions = @suite_result.assertion_count - @last_assertion_count
          @last_assertion_count = @suite_result.assertion_count
          @report_manager.write_report(@current_suite)
        end
      end

      def start_test(test_name)
        tc = TestCase.new(test_name)
        tc.start
        @current_suite.testcases << tc
      end

      def finish_test
        tc = @current_suite.testcases.last
        tc.finish
        tc.assertions = @suite_result.assertion_count - @result_assertion_count
        @result_assertion_count = @suite_result.assertion_count
      end
    end
  end
end
