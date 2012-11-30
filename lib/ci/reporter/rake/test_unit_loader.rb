# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

$: << File.dirname(__FILE__) + "/../../.."
require 'ci/reporter/test_unit'

# Intercepts mediator creation in ruby-test < 2.1
module Test #:nodoc:all
  module Unit
    module UI
      module Console
        class TestRunner
          undef :create_mediator if instance_methods.map(&:to_s).include?("create_mediator")
          def create_mediator(suite)
            # swap in our custom mediator
            return CI::Reporter::TestUnit.new(suite)
          end
        end
      end
    end
  end
end

# Intercepts mediator creation in ruby-test >= 2.1
module Test #:nodoc:all
  module Unit
    module UI
      class TestRunner
        undef :setup_mediator if instance_methods.map(&:to_s).include?("setup_mediator")
        def setup_mediator
          # swap in our custom mediator
          @mediator = CI::Reporter::TestUnit.new(@suite)
        end
      end
    end
  end
end
