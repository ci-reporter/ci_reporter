# Copyright (c) 2006-2010 Nick Sieger <nicksieger@gmail.com>
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
        def setup_mediator
          # swap in our custom mediator
          @mediator = CI::Reporter::TestUnit.new(@suite)
        end
      end
    end
  end
end
