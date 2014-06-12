# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'ci/reporter/core'

module CI
  module Reporter
    module RSpecFormatters
      require 'rspec/core/formatters/base_formatter'
      require 'rspec/core/formatters/progress_formatter'
      require 'rspec/core/formatters/documentation_formatter'
      BaseFormatter = ::RSpec::Core::Formatters::BaseFormatter
      ProgressFormatter = ::RSpec::Core::Formatters::ProgressFormatter
      DocFormatter = ::RSpec::Core::Formatters::DocumentationFormatter
      # See https://github.com/nicksieger/ci_reporter/issues/76 and
      #     https://github.com/nicksieger/ci_reporter/issues/80
      require 'rspec/core/version'
      RSpec_2_12_0_bug = (::RSpec::Core::Version::STRING == '2.12.0' &&
                          !BaseFormatter.instance_methods(false).map(&:to_s).include?("format_backtrace"))
    end

    # Wrapper around a <code>RSpec</code> error or failure to be used by the test suite to interpret results.
    class RSpec2Failure
      attr_reader :exception

      def initialize(example, formatter)
        @formatter = formatter
        @example = example
        if @example.respond_to?(:execution_result)
          @exception = @example.execution_result[:exception] || @example.execution_result[:exception_encountered]
        else
          @exception = @example.metadata[:execution_result][:exception]
        end
      end

      def name
        @exception.class.name
      end

      def message
        @exception.message
      end

      def failure?
        exception.is_a?(::RSpec::Expectations::ExpectationNotMetError)
      end

      def error?
        !failure?
      end

      def location
        output = []
        output.push "#{exception.class.name << ":"}" unless exception.class.name =~ /RSpec/
        output.push @exception.message

        format_metadata = RSpecFormatters::RSpec_2_12_0_bug ? @example.metadata : @example

        [@formatter.format_backtrace(@exception.backtrace, format_metadata)].flatten.each do |backtrace_info|
          backtrace_info.lines.each do |line|
            output.push "     #{line}"
          end
        end
        output.join "\n"
      end
    end

    class RSpecFormatter < ::RSpec::Core::Formatters::ProgressFormatter
      attr_accessor :suite, :report_manager
      if ::RSpec::Core::Formatters.respond_to?(:register)
        ::RSpec::Core::Formatters.register self, :example_group_started,
                                          :example_started, :example_passed, :example_failed,
                                          :example_pending, :dump_summary
      end

      def initialize(output)
        super
        @report_manager = ReportManager.new("spec")
      end

      def example_group_started(notification)
        super
        new_suite(description_for(notification.group))
      end

      def example_started(notification)
        super
        spec = TestCase.new
        @suite.testcases << spec
        spec.start
      end

      def example_passed(notification)
        super
        spec = @suite.testcases.last
        spec.finish
        spec.name = description_for(notification.example)
      end


      def example_failed(notification, *rest)
        super
        output.puts notification.example.execution_result
        #
        # In case we fail in before(:all)
        example_started(notification) if @suite.testcases.empty?
        failure = RSpec2Failure.new(notification.example, self)

        spec = @suite.testcases.last
        spec.finish
        spec.name = description_for(notification.example)
        spec.failures << failure
      end


      def dump_summary(summary)
        write_report
      end

      def write_report
        suite.finish
        report_manager.write_report(suite)
      end

      def new_suite(name)
        write_report if @suite
        @suite = TestSuite.new name
        @suite.start
      end

      private
      def description_for(name_or_example)
        if name_or_example.respond_to?(:full_description)
          name_or_example.full_description
        elsif name_or_example.respond_to?(:metadata)
          name_or_example.metadata[:example_group][:full_description]
        elsif name_or_example.respond_to?(:description)
          name_or_example.description
        else
          "UNKNOWN"
        end
      end



    end

    # Custom +RSpec+ formatter used to hook into the spec runs and capture results.
    class LegacyRSpecFormatter
      attr_accessor :report_manager
      attr_accessor :formatter
      def initialize(*args)
        @formatter ||= RSpecFormatters::ProgressFormatter.new(*args)
        @report_manager = ReportManager.new("spec")
        @suite = nil
      end

      def example_group_started(example_group)
        @formatter.example_group_started(example_group)
        new_suite(description_for(example_group))
      end

      def example_started(name_or_example)
        @formatter.example_started(name_or_example)
        spec = TestCase.new
        @suite.testcases << spec
        spec.start
      end

      def example_failed(name_or_example, *rest)
        @formatter.example_failed(name_or_example, *rest)

        # In case we fail in before(:all)
        example_started(name_or_example) if @suite.testcases.empty?

        failure = RSpec2Failure.new(name_or_example, @formatter)

        spec = @suite.testcases.last
        spec.finish
        spec.name = description_for(name_or_example)
        spec.failures << failure
      end

      def example_passed(name_or_example)
        @formatter.example_passed(name_or_example)
        spec = @suite.testcases.last
        spec.finish
        spec.name = description_for(name_or_example)
      end

      def example_pending(*args)
        @formatter.example_pending(*args)
        name = description_for(args[0])
        spec = @suite.testcases.last
        spec.finish
        spec.name = "#{name} (PENDING)"
        spec.skipped = true
      end

      def dump_summary(*args)
        @formatter.dump_summary(*args)
        write_report
        @formatter.dump_failures
      end

      def respond_to?(*args)
        @formatter.respond_to?(*args)
      end

      # Pass through other methods to RSpec formatter for compatibility
      def method_missing(meth,*args,&block)
        @formatter.send(meth,*args,&block)
      end

      private
      def description_for(name_or_example)
        if name_or_example.respond_to?(:full_description)
          name_or_example.full_description
        elsif name_or_example.respond_to?(:metadata)
          name_or_example.metadata[:example_group][:full_description]
        elsif name_or_example.respond_to?(:description)
          name_or_example.description
        else
          "UNKNOWN"
        end
      end

      def write_report
        if @suite
          @suite.finish
          @report_manager.write_report(@suite)
        end
      end

      def new_suite(name)
        write_report if @suite
        @suite = TestSuite.new name
        @suite.start
      end
    end


    if RSpec::Core::Version::STRING.split(".").first == '3'
      RSpec = RSpecFormatter
    else
      RSpec = LegacyRSpecFormatter
    end

    class RSpecDoc < RSpec
      def initialize(*args)
        @formatter = RSpecFormatters::DocFormatter.new(*args)
        super
      end
    end

    class RSpecBase < RSpec
      def initialize(*args)
        @formatter = RSpecFormatters::BaseFormatter.new(*args)
        super
      end
    end

  end
end
