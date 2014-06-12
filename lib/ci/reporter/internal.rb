module CI
  module Reporter
    module Internal
      def run_ruby_acceptance(cmd)
        ENV['CI_REPORTS'] ||= "acceptance/reports"
        if ENV['RUBYOPT']
          opts = ENV['RUBYOPT']
          ENV['RUBYOPT'] = nil
        else
          opts = "-rubygems"
        end
        begin
          result_proc = proc {|ok,*| puts "Failures above are expected." unless ok }
          ruby "-Ilib #{opts} #{cmd}", &result_proc
        ensure
          ENV['RUBYOPT'] = opts if opts != "-rubygems"
          ENV.delete 'CI_REPORTS'
        end
      end

      def save_env(v)
        ENV["PREV_#{v}"] = ENV[v]
      end

      def restore_env(v)
        ENV[v] = ENV["PREV_#{v}"]
        ENV.delete("PREV_#{v}")
      end
    end
  end
end
