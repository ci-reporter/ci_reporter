# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'delegate'
require 'stringio'

module CI
  module Reporter
    # Emulates/delegates IO to $stdout or $stderr in order to capture output to report in the XML file.
    module OutputCapture
      class Delegate < DelegateClass(IO)
        include OutputCapture
        def initialize(io, &assign)
          super(io)
          capture(io, &assign)
        end
      end

      def self.wrap(io, &assign)
        if defined?(RUBY_ENGINE) # JRuby, Ruby 1.9, etc.
          Delegate.new(io, &assign)
        else          # Ruby 1.8 requires streams to be subclass of IO
          IO.new(io.fileno, "w").tap {|x| x.extend self; x.capture(io, &assign) }
        end
      end

      # Start capturing IO, using the given block to assign self to the proper IO global.
      def capture(io, &assign)
        @delegate_io = io
        @captured_io = StringIO.new
        @assign_block = assign
        @assign_block.call @captured_io
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
    class TestSuite < Struct.new(:name, :tests, :time, :failures, :errors, :skipped, :assertions)
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
          @capture_out = OutputCapture.wrap($stdout) {|io| $stdout = io }
          @capture_err = OutputCapture.wrap($stderr) {|io| $stderr = io }
        end
      end

      # Finishes timing the test suite.
      def finish
        self.tests = testcases.size
        self.time = Time.now - @start
        self.failures = testcases.inject(0) {|sum,tc| sum += tc.failures.select{|f| f.failure? }.size }
        self.errors = testcases.inject(0) {|sum,tc| sum += tc.failures.select{|f| f.error? }.size }
        self.skipped = testcases.inject(0) {|sum,tc| sum += (tc.skipped? ? 1 : 0) }
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

      def skipped?
        return skipped
      end

      # Writes xml representing the test result to the provided builder.
      def to_xml(builder)
        attrs = {}
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) unless v.nil? || v.to_s.empty?}
        builder.testcase(attrs) do
          if skipped
            builder.skipped
          else
            failures.each do |failure|
              tag = case failure.class.name
                    when /TestUnitSkipped/ then :skipped
                    when /TestUnitError/, /MiniTestError/ then :error
                    else :failure end

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
