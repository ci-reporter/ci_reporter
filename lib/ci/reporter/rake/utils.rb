# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

module CI
  module Reporter
    def self.maybe_quote_filename(fn)
      if fn =~ /\s/
        fn = %{"#{fn}"}
      end
      fn
    end
  end
end
