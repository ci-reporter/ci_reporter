# Copyright (c) 2012 Alexander Shcherbinin <alexander.shcherbinin@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'ci/reporter/core'

require 'minitest/unit'

module CI
  module Reporter
    class Failure
      def self.new(fault, type = nil, meth = nil)
        return MiniTestSkipped.new(fault) if type == :skip
        return MiniTestFailure.new(fault, meth) if type == :failure
        MiniTestError.new(fault)
      end
    end

    class FailureCore
      def location(e)
        last_before_assertion = ""
        e.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
          last_before_assertion = s
        end
        last_before_assertion.sub(/:in .*$/, '')
      end
    end

    class MiniTestSkipped < FailureCore
      def initialize(fault) @fault = fault end
      def failure?() false end
      def error?() false end
      def name() @fault.class.name end
      def message() @fault.message end
      def location() super @fault end
    end

    class MiniTestFailure < FailureCore
      def initialize(fault, meth) @fault = fault; @meth = meth end
      def failure?() true end
      def error?() false end
      def name() @meth end
      def message() @fault.message end
      def location() super @fault end
    end

    class MiniTestError < FailureCore
      def initialize(fault) @fault = fault end
      def failure?() false end
      def error?() true end
      def name() @fault.class.name end
      def message() @fault.message end
      def location() @fault.backtrace.join("\n") end
    end

    class Runner < MiniTest::Unit

      @@out = $stdout

      def initialize
        super
        @report_manager = ReportManager.new("test")
      end

      def _run_anything(type)
        suites = MiniTest::Unit::TestCase.send "#{type}_suites"
        return if suites.empty?

        started_anything type

        sync = output.respond_to? :"sync=" # stupid emacs
        old_sync, output.sync = output.sync, true if sync

        _run_suites(suites, type)

        output.sync = old_sync if sync

        finished_anything(type)
      end

      def _run_suites(suites, type)
        suites.map { |suite| _run_suite suite, type }
      end

      def _run_suite(suite, type)
        start_suite(suite)

        header = "#{type}_suite_header"
        puts send(header, suite) if respond_to? header

        filter_suite_methods(suite, type).each do |method|
          _run_test(suite, method)
        end

        finish_suite
      end

      def _run_test(suite, method)
        start_case(method)

        result = run_test(suite, method)

        @assertion_count += result._assertions
        @test_count += 1

        finish_case
      end

      def puke(klass, meth, e)
        e = case e
            when MiniTest::Skip then
              @skips += 1
              fault(e, :skip)
              return "S" unless @verbose
              "Skipped:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n"
            when MiniTest::Assertion then
              @failures += 1
              fault(e, :failure, meth)
              "Failure:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n"
            else
              @errors += 1
              fault(e, :error)
              bt = MiniTest::filter_backtrace(e.backtrace).join "\n    "
              "Error:\n#{meth}(#{klass}):\n#{e.class}: #{e.message}\n    #{bt}\n"
            end
        @report << e
        e[0, 1]
      end

      private

      def started_anything(type)
        @test_count = 0
        @assertion_count = 0
        @last_assertion_count = 0
        @result_assertion_count = 0
        @start = Time.now

        puts
        puts "# Running #{type}s:"
        puts
      end

      def finished_anything(type)
        t = Time.now - @start
        puts
        puts
        puts "Finished #{type}s in %.6fs, %.4f tests/s, %.4f assertions/s." %
          [t, @test_count / t, @assertion_count / t]

        report.each_with_index do |msg, i|
          puts "\n%3d) %s" % [i + 1, msg]
        end

        puts

        status
      end

      def filter_suite_methods(suite, type)
        filter = options[:filter] || '/./'
        filter = Regexp.new $1 if filter =~ /\/(.*)\//

        suite.send("#{type}_methods").grep(filter)
      end

      def run_test(suite, method)
        inst = suite.new method
        inst._assertions = 0

        print "#{suite}##{method} = " if @verbose

        @start_time = Time.now
        result = inst.run self
        time = Time.now - @start_time

        print "%.2f s = " % time if @verbose
        print result
        puts if @verbose

        return inst
      end

      def start_suite(suite_name)
        @current_suite = CI::Reporter::TestSuite.new(suite_name)
        @current_suite.start
      end

      def finish_suite
        if @current_suite
          @current_suite.finish
          @current_suite.assertions = @assertion_count - @last_assertion_count
          @last_assertion_count = @assertion_count
          @report_manager.write_report(@current_suite)
        end
      end

      def start_case(test_name)
        tc = CI::Reporter::TestCase.new(test_name)
        tc.start
        @current_suite.testcases << tc
      end

      def finish_case
        tc = @current_suite.testcases.last
        tc.finish
        tc.assertions = @assertion_count - @result_assertion_count
        @result_assertion_count = @assertion_count
      end

      def fault(fault, type = nil, meth = nil)
        tc = @current_suite.testcases.last
        if :skip == type
          tc.skipped = true
        else
          tc.failures << Failure.new(fault, type, meth)
        end
      end

    end

  end
end
