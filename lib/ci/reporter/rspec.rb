# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'ci/reporter/core'
begin
  gem 'rspec'
rescue Gem::LoadError
  # Needed for non-gem RSpec (e.g., reporting on RSpec's own specs);
  # if spec isn't found, the next require will blow up
end
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
        if respond_to? :dry_run=
          super(output)
          self.dry_run=dry_run
          self.colour=colour
        else
          super(output, dry_run, colour)
        end
        @report_manager = report_mgr || ReportManager.new("spec")
        @suite = nil
      end

      def start(spec_count)
        super
      end

      # Pre-0.9 hook
      def add_context(name, first)
        super
        new_suite(name)
      end

      # Post-0.9 hook
      def add_behaviour(name)
        super
        new_suite(name)
      end

      # Pre-0.9 hook
      def spec_started(name)
        super
        case_started(name)
      end

      # Post-0.9 hook
      def example_started(name)
        super
        case_started(name)
      end

      # Pre-0.9 hook
      def spec_failed(name, counter, failure)
        super
        case_failed(name, counter, failure)
      end

      # Post-0.9 hook
      def example_failed(name, counter, failure)
        super
        case_failed(name, counter, failure)
      end

      # Pre-0.9 hook
      def spec_passed(name)
        super
        case_passed(name)
      end

      # Post-0.9 hook
      def example_passed(name)
        super
        case_passed(name)
      end

      def start_dump
        super
      end

      def dump_failure(counter, failure)
        super
      end

      def dump_summary(duration, example_count, failure_count, not_implemented_count = 0)
        begin
          super
        rescue ArgumentError
          super(duration, example_count, failure_count)
        end
        write_report
      end

      private
      def write_report
        @suite.finish
        @report_manager.write_report(@suite)
      end

      def new_suite(name)
        write_report if @suite
        @suite = TestSuite.new name
        @suite.start
      end

      def case_started(name)
        spec = TestCase.new name
        @suite.testcases << spec
        spec.start
      end

      def case_failed(name, counter, failure)
        spec = @suite.testcases.last
        spec.finish
        spec.failures << RSpecFailure.new(failure)
      end

      def case_passed(name)
        spec = @suite.testcases.last
        spec.finish
      end
    end
  end
end