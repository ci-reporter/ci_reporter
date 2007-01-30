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
            gem 'activesupport'
            require 'active_support'
          rescue
            raise LoadError, "XML Builder is required by CI::Reporter"
          end
        end unless defined?(Builder::XmlMarkup)
        # :escape_attrs is obsolete in a newer version, but should do no harm
        Builder::XmlMarkup.new(:indent => 2, :escape_attrs => true)
      end

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
        each_pair {|k,v| attrs[k] = builder.trunc!(v.to_s) }
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