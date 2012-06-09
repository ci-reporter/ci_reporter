# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'rexml/document'

describe "Output capture" do
  before(:each) do
    @suite = CI::Reporter::TestSuite.new "test"
  end

  it "should save stdout and stderr messages written during the test run" do
    @suite.start
    puts "Hello"
    $stderr.print "Hi"
    @suite.finish
    @suite.stdout.should == "Hello\n"
    @suite.stderr.should == "Hi"
  end

  it "should include system-out and system-err elements in the xml output" do
    @suite.start
    puts "Hello"
    $stderr.print "Hi"
    @suite.finish

    root = REXML::Document.new(@suite.to_xml).root
    root.elements.to_a('//system-out').length.should == 1
    root.elements.to_a('//system-err').length.should == 1
    root.elements.to_a('//system-out').first.texts.first.to_s.strip.should == "Hello"
    root.elements.to_a('//system-err').first.texts.first.to_s.strip.should == "Hi"
  end

  it "should return $stdout and $stderr to original value after finish" do
    out, err = $stdout, $stderr
    @suite.start
    $stdout.object_id.should_not == out.object_id
    $stderr.object_id.should_not == err.object_id
    @suite.finish
    $stdout.object_id.should == out.object_id
    $stderr.object_id.should == err.object_id
  end
  
  it "should capture only during run of owner test suite" do
    $stdout.print "A"
    $stderr.print "A"
    @suite.start
    $stdout.print "B"
    $stderr.print "B"
    @suite.finish
    $stdout.print "C"
    $stderr.print "C"
    @suite.stdout.should == "B"
    @suite.stderr.should == "B"
  end
  
  it "should not barf when commands are executed with back-ticks" do
    @suite.start
    `echo "B"`
    @suite.finish
  end
  
end
