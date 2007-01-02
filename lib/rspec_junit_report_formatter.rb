require 'fileutils'

module RSpec
  class JUnitReportFormatter < Spec::Runner::Formatter::ProgressBarFormatter
    class Context < Struct.new(:name, :tests, :time, :failures, :errors)
      attr_accessor :testcases
      def initialize(name)
        super
        @testcases = []
      end

      def start
        @start = Time.now
      end

      def finish
        self.tests = testcases.size
        self.time = Time.now - @start
        self.failures = testcases.select {|tc| tc.failure? }.size
        self.errors = testcases.select {|tc| tc.error? }.size
      end

      def create_builder
        begin
          require 'builder'
        rescue LoadError
          begin
            require_gem 'activesupport'
            require 'active_support'
          rescue
            raise LoadError, "XML Builder is required for the JUnitReportFormatter"
          end
        end unless defined?(Builder::XmlMarkup)
        Builder::XmlMarkup.new(:indent => 2)
      end

      def to_xml
        builder = create_builder
        builder.instruct!
        attrs = {}
        each_pair {|k,v| attrs[k] = v.to_s }
        builder.testsuite(attrs) do
          @testcases.each do |tc|
            tc.to_xml(builder)
          end
        end
      end
    end

    class Spec < Struct.new(:name, :time)
      attr_accessor :failure

      def start
        @start = Time.now
      end

      def finish
        self.time = Time.now - @start
      end

      def failure?
        failure && failure.expectation_not_met?
      end

      def error?
        failure && !failure.expectation_not_met?
      end

      def to_xml(builder)
        attrs = {}
        each_pair {|k,v| attrs[k] = v.to_s }
        builder.testcase(attrs) do
          if failure
            exception = failure.exception
            builder.failure(:type => exception.class.name, :message => exception.message) do
              builder.text!(exception.backtrace.join("\n"))
            end
          end
        end
      end
    end

    def initialize(output, dry_run=false, colour=false)
      super
      @basedir = File.expand_path("#{Dir.getwd}/spec/reports")
      @basename = "#{@basedir}/SPEC"
      FileUtils.mkdir_p(@basedir)
      @context = nil
    end

    def start(spec_count)
      super
    end

    def add_context(name, first)
      super
      write_report if @context
      @context = Context.new name
      @context.start
    end

    def spec_started(name)
      super
      spec = Spec.new name
      @context.testcases << spec
      spec.start
    end

    def spec_failed(name, counter, failure)
      super
      spec = @context.testcases.last
      spec.finish
      spec.failure = failure
    end

    def spec_passed(name)
      super
      spec = @context.testcases.last
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
      @context.finish
      File.open("#{@basename}-#{@context.name.gsub(/[^a-zA-Z0-9]+/, '-')}.xml", "w") do |f|
        f << @context.to_xml
      end
    end
  end
end