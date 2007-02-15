require 'ci/reporter/core'
gem 'rspec'
require 'spec'

module CI
  module Reporter
    # Wrapper around a <code>RSpec</code> error or failure to be used by the test suite to interpret results.
    class RSpecFailure
      def initialize(failure)
        @failure = failure
      end

      def failure?
        @failure.expectation_not_met?
      end

      def error?
        !@failure.expectation_not_met?
      end

      def name() @failure.exception.class.name end
      def message() @failure.exception.message end
      def location() @failure.exception.backtrace.join("\n") end
    end

    # Custom +RSpec+ formatter used to hook into the spec runs and capture results.
    class RSpec < Spec::Runner::Formatter::ProgressBarFormatter
      def initialize(output, dry_run=false, colour=false, report_mgr=nil)
        super(output, dry_run, colour)
        @report_manager = report_mgr || ReportManager.new("spec")
        @suite = nil
      end

      def start(spec_count)
        super
      end

      def add_context(name, first)
        super
        write_report if @suite
        @suite = TestSuite.new name
        @suite.start
      end

      def spec_started(name)
        super
        spec = TestCase.new name
        @suite.testcases << spec
        spec.start
      end

      def spec_failed(name, counter, failure)
        super
        spec = @suite.testcases.last
        spec.finish
        spec.failure = RSpecFailure.new(failure)
      end

      def spec_passed(name)
        super
        spec = @suite.testcases.last
        spec.finish
      end

      def start_dump
        super
      end

      def dump_failure(counter, failure)
        super
      end

      def dump_summary(duration, spec_count, failure_count)
        super
        write_report
      end

      private
      def write_report
        @suite.finish
        @report_manager.write_report(@suite)
      end
    end
  end
end