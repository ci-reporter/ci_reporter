require 'time'
require 'ci/reporter/output_capture'

module CI
  module Reporter
    # Basic structure representing the running of a test suite.  Used to time tests and store results.
    class TestSuite < Struct.new(:name, :tests, :time, :failures, :errors, :skipped, :assertions, :timestamp)
      attr_accessor :testcases
      attr_accessor :stdout, :stderr
      def initialize(name)
        super(name.to_s) # RSpec passes a "description" object instead of a string
        @testcases = []
      end

      # Starts timing the test suite.
      def start
        @start = Time.now
        unless ENV['CI_CAPTURE'] == "off"
          @capture_out = OutputCapture.new($stdout) {|io| $stdout = io }
          @capture_err = OutputCapture.new($stderr) {|io| $stderr = io }
          @capture_out.start
          @capture_err.start
        end
      end

      # Finishes timing the test suite.
      def finish
        self.tests = testcases.size
        self.time = Time.now - @start
        self.timestamp = @start.iso8601
        self.failures = testcases.map(&:failure_count).reduce(&:+)
        self.errors = testcases.map(&:error_count).reduce(&:+)
        self.skipped = testcases.count(&:skipped?)
        self.stdout = @capture_out.finish if @capture_out
        self.stderr = @capture_err.finish if @capture_err
      end

      # Creates the xml builder instance used to create the report xml document.
      def create_builder
        require 'builder'
        # :escape_attrs is obsolete in a newer version, but should do no harm
        Builder::XmlMarkup.new(:indent => 2, :escape_attrs => true)
      end

      # Creates an xml string containing the test suite results.
      def to_xml
        builder = create_builder
        # more recent version of Builder doesn't need the escaping
        def builder.trunc!(txt)
          txt.sub(/\n.*/m, '...')
        end
        builder.instruct!
        attrs = {}
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) unless v.nil? || v.to_s.empty? }
        builder.testsuite(attrs) do
          @testcases.each do |tc|
            tc.to_xml(builder)
          end
          builder.tag! "system-out" do
            builder.text!(self.stdout || '' )
          end
          builder.tag! "system-err" do
            builder.text!(self.stderr || '' )
          end
        end
      end
    end

    # Structure used to represent an individual test case.  Used to time the test and store the result.
    class TestCase < Struct.new(:name, :time, :assertions)
      attr_accessor :failures
      attr_accessor :skipped

      def initialize(*args)
        super
        @failures = []
      end

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
        !failures.empty? && failures.detect {|f| f.failure? }
      end

      # Returns non-nil if the test had an error.
      def error?
        !failures.empty? && failures.detect {|f| f.error? }
      end

      def failure_count
        failures.count(&:failure?)
      end

      def error_count
        failures.count(&:error?)
      end

      def skipped?
        skipped
      end

      # Writes xml representing the test result to the provided builder.
      def to_xml(builder)
        attrs = {}
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) unless v.nil? || v.to_s.empty?}
        builder.testcase(attrs) do
          if skipped?
            builder.skipped
          else
            failures.each do |failure|
              tag = failure.error? ? :error : :failure

              builder.tag!(tag, :type => builder.trunc!(failure.name), :message => builder.trunc!(failure.message)) do
                builder.text!(failure.message + " (#{failure.name})\n")
                builder.text!(failure.location)
              end
            end
          end
        end
      end
    end
  end
end
