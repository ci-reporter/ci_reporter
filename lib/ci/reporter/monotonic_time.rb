module CI
  module Reporter
    module MonotonicTime
      module_function

      if defined?(Process::CLOCK_MONOTONIC)
        def time_in_nanoseconds
          Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
        end
      else
        def time_in_nanoseconds
          t = Time.now
          t.to_i * 10 ** 9 + t.nsec
        end
      end

      def time_in_seconds
        time_in_nanoseconds / 10 ** 9.0
      end
    end
  end
end
