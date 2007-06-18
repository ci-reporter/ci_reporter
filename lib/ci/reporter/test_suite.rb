# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'delegate'
require 'stringio'

module CI
  module Reporter
    # Emulates/delegates IO to $stdout or $stderr in order to capture output to report in the XML file.
    class OutputCapture < DelegateClass(IO)
      # Start capturing IO, using the given block to assign self to the proper IO global.
      def initialize(io, &assign)
        super
        @delegate_io = io
        @captured_io = StringIO.new
        @assign_block = assign
        @assign_block.call self
      end

      # Finalize the capture and reset to the original IO object.
      def finish
        @assign_block.call @delegate_io
        @captured_io.string
      end

      # setup tee methods
      %w(<< print printf putc puts write).each do |m|
        module_eval(<<-EOS, __FILE__, __LINE__)
          def #{m}(*args, &block)
            @delegate_io.send(:#{m}, *args, &block)
            @captured_io.send(:#{m}, *args, &block)
          end
        EOS
      end
    end

    # Basic structure representing the running of a test suite.  Used to time tests and store results.
    class TestSuite < Struct.new(:name, :tests, :time, :failures, :errors, :assertions)
      attr_accessor :testcases
      attr_accessor :stdout, :stderr
      def initialize(name)
        super
        @testcases = []
      end

      # Starts timing the test suite.
      def start
        @start = Time.now
        unless ENV['CI_CAPTURE'] == "off"
          @capture_out = OutputCapture.new($stdout) {|io| $stdout = io }
          @capture_err = OutputCapture.new($stderr) {|io| $stderr = io }
        end
      end

      # Finishes timing the test suite.
      def finish
        self.tests = testcases.size
        self.time = Time.now - @start
        self.failures = testcases.select {|tc| tc.failure? }.size
        self.errors = testcases.select {|tc| tc.error? }.size
        self.stdout = @capture_out.finish if @capture_out
        self.stderr = @capture_err.finish if @capture_err
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
          builder.tag! "system-out" do
            builder.cdata! self.stdout
          end
          builder.tag! "system-err" do
            builder.cdata! self.stderr
          end
        end
      end
    end

    # Structure used to represent an individual test case.  Used to time the test and store the result.
    class TestCase < Struct.new(:name, :time, :assertions)
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
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) unless v.nil? || v.to_s.empty?}
        builder.testcase(attrs) do
          if failure
            builder.failure(:type => builder.trunc!(failure.name), :message => builder.trunc!(failure.message)) do
              builder.text!(failure.message + " (#{failure.name})\n")
              builder.text!(failure.location)
            end
          end
        end
      end
    end
  end
end