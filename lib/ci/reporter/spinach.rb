require 'ci/reporter/core'
require 'spinach'

module CI
  module Reporter
    class Spinach < ::Spinach::Reporter
      def initialize(options = nil)
        @options = options
        @report_manager = ReportManager.new('features')
      end

      def before_feature_run(feature)
        @test_suite = TestSuite.new(feature.is_a?(Hash) ? feature['name'] : feature.name)
        @test_suite.start
      end

      def before_scenario_run(scenario, step_definitions = nil)
        @test_case = TestCase.new(scenario.is_a?(Hash) ? scenario['name'] : scenario.name)
        @test_case.start
      end

      def on_undefined_step(step, failure, step_definitions = nil)
        @test_case.failures << SpinachFailure.new(:error, step, failure, nil)
      end

      def on_failed_step(step, failure, step_location, step_definitions = nil)
        @test_case.failures << SpinachFailure.new(:failed, step, failure, step_location)
      end

      def on_error_step(step, failure, step_location, step_definitions = nil)
        @test_case.failures << SpinachFailure.new(:error, step, failure, step_location)
      end

      def after_scenario_run(scenario, step_definitions = nil)
        @test_case.finish
        @test_suite.testcases << @test_case
        @test_case = nil
      end

      def after_feature_run(feature)
        @test_suite.finish
        @report_manager.write_report(@test_suite)
        @test_suite = nil
      end
    end

    class SpinachFailure
      def initialize(type, step, failure, step_location)
        @type = type
        @step = step
        @failure = failure
        @step_location = step_location
      end

      def failure?
        @type == :failed
      end

      def error?
        @type == :error
      end

      def name
        @failure.class.name
      end

      def message
        @failure.message
      end

      def location
        @failure.backtrace.join("\n")
      end
    end
  end
end

class Spinach::Reporter
  CiReporter = ::CI::Reporter::Spinach
end
