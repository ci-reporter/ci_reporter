require 'rexml/document'

REPORTS_DIR = File.dirname(__FILE__) + '/reports'

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
    doc.root.elements.to_a("/testsuite/testcase/failure").size.should == 2
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
    failures.first.attributes["type"].should == "Spec::Expectations::ExpectationNotMetError"
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

describe "Cucumber acceptance" do
  it "should generate two XML files" do
    File.exist?(File.join(REPORTS_DIR, 'CUCUMBER-Feature-Example-feature-Conscientious-developer.xml')).should == true
    File.exist?(File.join(REPORTS_DIR, 'CUCUMBER-Feature-Example-feature-Lazy-hacker.xml')).should == true
  end

  it "should have three tests and no failures for the conscientious developer" do
    doc = File.open(File.join(REPORTS_DIR, 'CUCUMBER-Feature-Example-feature-Conscientious-developer.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "0"
    doc.root.attributes["failures"].should == "0"
    doc.root.attributes["tests"].should == "3"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 3
  end

  it "should have three tests, one failure and one error (skipped) for the lazy hacker" do
    doc = File.open(File.join(REPORTS_DIR, 'CUCUMBER-Feature-Example-feature-Lazy-hacker.xml')) do |f|
      REXML::Document.new(f)
    end
    doc.root.attributes["errors"].should == "1"
    doc.root.attributes["failures"].should == "1"
    doc.root.attributes["tests"].should == "3"
    doc.root.elements.to_a("/testsuite/testcase").size.should == 3

    failures = doc.root.elements.to_a("/testsuite/testcase/failure")
    failures.size.should == 1
    failures.first.attributes["type"].should == "Spec::Expectations::ExpectationNotMetError"

    error = doc.root.elements.to_a("/testsuite/testcase/error")
    error.size.should == 1
    error.first.attributes["type"].should == "Skipped"
  end
end
