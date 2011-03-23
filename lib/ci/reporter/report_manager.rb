# Copyright (c) 2006-2010 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'fileutils'

module CI #:nodoc:
  module Reporter #:nodoc:
    class ReportManager
      UNIQUE_SUFFIX_LENGTH = 8

      def initialize(prefix)
        @basedir = ENV['CI_REPORTS'] || File.expand_path("#{Dir.getwd}/#{prefix.downcase}/reports")
        @basename = "#{@basedir}/#{prefix.upcase}"
        @max_filename_length = ENV['CI_MAX_FILENAME_LENGTH'].to_i
        if @max_filename_length != 0
          min_acceptable_max = UNIQUE_SUFFIX_LENGTH + '.xml'.length
          unless @max_filename_length > min_acceptable_max
            raise ArgumentError, "CI_MAX_FILENAME_LENGTH must exceed #{min_acceptable_max}!"
          end
          @max_filename_length -= '.xml'.length
        end
        FileUtils.mkdir_p(@basedir)
      end
      
      def write_report(suite)
        File.open(report_filename(suite), "w") do |f|
          f << suite.to_xml
        end
      end

      private
      def report_filename(suite)
        ideal = "#{@basename}-#{suite.name.gsub(/[^a-zA-Z0-9]+/, '-')}"

        if @max_filename_length == 0 || ideal.length <= @max_filename_length
          return "#{ideal}.xml"
        end

        suffix = "%0#{UNIQUE_SUFFIX_LENGTH}d" % rand(10 ** UNIQUE_SUFFIX_LENGTH)
        ideal[0, @max_filename_length - UNIQUE_SUFFIX_LENGTH] + suffix + '.xml'
      end
    end
  end
end
