require 'test/unit'
require 'test/unit/ui/console/testrunner'

module CI
  module Reporter
    class TestUnitFailure
      def initialize(fault)
        @fault = fault
      end
      def failure?
        @fault.kind_of? Test::Unit::Failure
      end

      def error?
        @fault.kind_of? Test::Unit::Error
      end

      def exception
        @fault.exception
      end
    end

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
        @suite = nil
        @unknown_count = 0
      end

      def test_started(name)
        test_name, suite_name = extract_names(name)
        unless @suite && @suite.name == suite_name
          finish_suite
          start_suite(suite_name)
        end
        start_test(test_name)
      end

      def test_finished(name)
        finish_test
      end

      def fault(fault)
        finish_test(fault)
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
        @suite = TestSuite.new(suite_name)
        @suite.start
      end

      def finish_suite
        if @suite
          @suite.finish 
          @report_manager.write_report(@suite)
        end
      end

      def start_test(test_name)
        tc = TestCase.new(test_name)
        tc.start
        @suite.testcases << tc
      end

      def finish_test(failure = nil)
        tc = @suite.testcases.last
        tc.finish
        tc.failure = TestUnitFailure.new(failure) if failure
      end
    end
  end
end