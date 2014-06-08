#--
# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require 'rexml/document'

ACCEPTANCE_DIR = File.dirname(__FILE__)
REPORTS_DIR = ACCEPTANCE_DIR + '/reports'

if Gem.loaded_specs['test-unit']
describe "Test::Unit acceptance" do
  it "should generate two XML files" do
    File.exist?(File.join(REPORTS_DIR, 'TEST-TestUnitExampleTestOne.xml')).should == true
    File.exist?(File.join(REPORTS_DIR, 'TEST-TestUnitExampleTestTwo.xml')).should == true
  end

  it "should have one error and one failure for TestUnitExampleTestOne" do
    doc = File.open(File.join(REPORTS_DIR, 'TEST-TestUnitExampleTestOne.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "1"
    doc.root.attributes["failures"].should == "1"
    doc.root.attributes["assertions"].should == "1"
    doc.root.attributes["tests"].should == "1"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 1
    doc.root.elements.to_a("/testsuite/testcase/error").size.should == 1
    doc.root.elements.to_a("/testsuite/testcase/failure").size.should == 1
    doc.root.elements.to_a("/testsuite/system-out").first.texts.inject("") do |c,e|
      c << e.value; c
    end.strip.should == "Some <![CDATA[on stdout]]>"
  end

  it "should have no errors or failures for TestUnitExampleTestTwo" do
    doc = File.open(File.join(REPORTS_DIR, 'TEST-TestUnitExampleTestTwo.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "0"
    doc.root.attributes["failures"].should == "0"
    doc.root.attributes["assertions"].should == "1"
    doc.root.attributes["tests"].should == "1"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 1
    doc.root.elements.to_a("/testsuite/testcase/failure").size.should == 0
  end
end
end

if Gem.loaded_specs['minitest']
describe "MiniTest::Unit acceptance" do
  it "should generate two XML files" do
    File.exist?(File.join(REPORTS_DIR, 'TEST-MiniTestExampleTestOne.xml')).should == true
    File.exist?(File.join(REPORTS_DIR, 'TEST-MiniTestExampleTestTwo.xml')).should == true
  end

  it "should have one error and one failure for MiniTestExampleTestOne" do
    doc = File.open(File.join(REPORTS_DIR, 'TEST-MiniTestExampleTestOne.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "1"
    doc.root.attributes["failures"].should == "1"
    doc.root.attributes["assertions"].should == "1"
    doc.root.attributes["tests"].should == "1"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 1
    doc.root.elements.to_a("/testsuite/testcase/error").size.should == 1
    doc.root.elements.to_a("/testsuite/testcase/failure").size.should == 1
    doc.root.elements.to_a("/testsuite/system-out").first.texts.inject("") do |c,e|
      c << e.value; c
    end.strip.should == "Some <![CDATA[on stdout]]>"
  end

  it "should have no errors or failures for MiniTestExampleTestTwo" do
    doc = File.open(File.join(REPORTS_DIR, 'TEST-MiniTestExampleTestTwo.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "0"
    doc.root.attributes["failures"].should == "0"
    doc.root.attributes["assertions"].should == "1"
    doc.root.attributes["tests"].should == "1"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 1
    doc.root.elements.to_a("/testsuite/testcase/failure").size.should == 0
  end
end
end

if Gem.loaded_specs['rspec-core']
describe "RSpec acceptance" do
  it "should generate two XML files" do
    File.exist?(File.join(REPORTS_DIR, 'SPEC-RSpec-example.xml')).should == true
    File.exist?(File.join(REPORTS_DIR, 'SPEC-RSpec-example-nested.xml')).should == true
  end

  it "should have two tests and one failure" do
    doc = File.open(File.join(REPORTS_DIR, 'SPEC-RSpec-example.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "0"
    doc.root.attributes["failures"].should == "1"
    doc.root.attributes["tests"].should == "3"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 3
    failures = doc.root.elements.to_a("/testsuite/testcase/failure")
    failures.size.should == 1
    failures.first.attributes["type"].should =~ /ExpectationNotMetError/
  end

  it "should have one test in the nested example report" do
    doc = File.open(File.join(REPORTS_DIR, 'SPEC-RSpec-example-nested.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "0"
    doc.root.attributes["failures"].should == "0"
    doc.root.attributes["tests"].should == "1"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 1
  end
end
end

['cucumber', 'spinach'].each do |gem|
  load ACCEPTANCE_DIR + "/verification_spec_#{gem}.rb" if Gem.loaded_specs[gem]
end
