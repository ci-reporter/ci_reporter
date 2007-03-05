module CI
  module Reporter
    # Basic structure representing the running of a test suite.  Used to time tests and store results.
    class TestSuite < Struct.new(:name, :tests, :time, :failures, :errors, :assertions)
      attr_accessor :testcases
      def initialize(name)
        super
        @testcases = []
      end

      # Starts timing the test suite.
      def start
        @start = Time.now
      end

      # Finishes timing the test suite.
      def finish
        self.tests = testcases.size
        self.time = Time.now - @start
        self.failures = testcases.select {|tc| tc.failure? }.size
        self.errors = testcases.select {|tc| tc.error? }.size
      end

      # Creates the xml builder instance used to create the report xml document.
      def create_builder
        begin
          gem 'builder'
          require 'builder'
        rescue
          begin
            gem 'activesupport'
            require 'active_support'
          rescue
            raise LoadError, "XML Builder is required by CI::Reporter"
          end
        end unless defined?(Builder::XmlMarkup)
        # :escape_attrs is obsolete in a newer version, but should do no harm
        Builder::XmlMarkup.new(:indent => 2, :escape_attrs => true)
      end

      # Creates an xml string containing the test suite results.
      def to_xml
        builder = create_builder
        # more recent version of Builder doesn't need the escaping
        if Builder::XmlMarkup.private_instance_methods.include?("_attr_value")
          def builder.trunc!(txt)
            txt.sub(/\n.*/m, '...')
          end
        else
          def builder.trunc!(txt)
            _escape(txt.sub(/\n.*/m, '...'))
          end
        end
        builder.instruct!
        attrs = {}
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) unless v.nil? || v.to_s.empty? }
        builder.testsuite(attrs) do
          @testcases.each do |tc|
            tc.to_xml(builder)
          end
        end
      end
    end

    # Structure used to represent an individual test case.  Used to time the test and store the result.
    class TestCase < Struct.new(:name, :time)
      attr_accessor :failure

      # Starts timing the test.
      def start
        @start = Time.now
      end

      # Finishes timing the test.
      def finish
        self.time = Time.now - @start
      end

      # Returns non-nil if the test failed.
      def failure?
        failure && failure.failure?
      end

      # Returns non-nil if the test had an error.
      def error?
        failure && failure.error?
      end

      # Writes xml representing the test result to the provided builder.
      def to_xml(builder)
        attrs = {}
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) }
        builder.testcase(attrs) do
          if failure
            builder.failure(:type => builder.trunc!(failure.name), :message => builder.trunc!(failure.message)) do
              builder.text!(failure.location)
            end
          end
        end
      end
    end
  end
end