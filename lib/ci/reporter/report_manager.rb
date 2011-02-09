# Copyright (c) 2006-2010 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'fileutils'
require 'digest/sha1'

module CI #:nodoc:
  module Reporter #:nodoc:
    class ReportManager
      def initialize(prefix)
        @basedir = ENV['CI_REPORTS'] || File.expand_path("#{Dir.getwd}/#{prefix.downcase}/reports")
        @basename = "#{prefix.upcase}"
        FileUtils.mkdir_p(@basedir)
      end
      
      def write_report(suite)
        File.open(filename(suite.name), "w") do |f|
          f << suite.to_xml
        end
      end

    protected
      
      def filename(test_name)
        filebase = "#{@basename}-#{test_name.gsub(/[^a-zA-Z0-9]+/, '-')}"
        if filebase.size > 251
          filebase = "#{filebase[0..209]}-#{Digest::SHA1.hexdigest(filebase[209..-1])}"
        end
        "#{@basedir}/#{filebase}.xml"
      end
    end
  end
end
