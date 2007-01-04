module CI
  module Reporter
    class TestSuite < Struct.new(:name, :tests, :time, :failures, :errors)
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
            raise LoadError, "XML Builder is required by CI::Reporter"
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

    class TestCase < Struct.new(:name, :time)
      attr_accessor :failure

      def start
        @start = Time.now
      end

      def finish
        self.time = Time.now - @start
      end

      def failure?
        failure && failure.failure?
      end

      def error?
        failure && failure.error?
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
  end
end