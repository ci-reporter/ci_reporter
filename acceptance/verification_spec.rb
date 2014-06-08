#--
# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require 'rexml/document'

ACCEPTANCE_DIR = File.dirname(__FILE__)
REPORTS_DIR = ACCEPTANCE_DIR + '/reports'

['test-unit', 'minitest', 'rspec-core'].each do |gem|
  load ACCEPTANCE_DIR + "/verification_spec_#{gem}.rb" if Gem.loaded_specs[gem]
end
