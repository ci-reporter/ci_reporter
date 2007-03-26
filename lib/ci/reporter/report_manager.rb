# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'fileutils'

module CI #:nodoc:
  module Reporter #:nodoc:
    class ReportManager
      def initialize(prefix)
        @basedir = ENV['CI_REPORTS'] || File.expand_path("#{Dir.getwd}/#{prefix.downcase}/reports")
        @basename = "#{@basedir}/#{prefix.upcase}"
        FileUtils.mkdir_p(@basedir)
      end
      
      def write_report(suite)
        File.open("#{@basename}-#{suite.name.gsub(/[^a-zA-Z0-9]+/, '-')}.xml", "w") do |f|
          f << suite.to_xml
        end
      end
    end
  end
end