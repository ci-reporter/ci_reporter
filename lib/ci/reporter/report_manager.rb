require 'fileutils'

module CI
  module Reporter
    class ReportManager
      def initialize(prefix="test")
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