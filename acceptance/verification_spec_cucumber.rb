describe "Cucumber acceptance" do
  it "should generate one XML file" do
    File.exist?(File.join(REPORTS_DIR, 'FEATURES-Example-Cucumber-feature.xml')).should == true

    Dir["#{REPORTS_DIR}/FEATURES-*Cucumber*.xml"].length.should == 1
  end

  context "FEATURES report file" do
    before :each do
      @doc = File.open(File.join(REPORTS_DIR, 'FEATURES-Example-Cucumber-feature.xml')) do |f|
        REXML::Document.new(f)
      end
    end

    it "should have three tests and two failures" do
      @doc.root.attributes["errors"].should == "0"
      @doc.root.attributes["failures"].should == "2"
      @doc.root.attributes["tests"].should == "3"
      @doc.root.elements.to_a("/testsuite/testcase").size.should == 3
    end

    it "should have one failure for the lazy hacker" do
      failures = @doc.root.elements.to_a("/testsuite/testcase[@name='Lazy hacker']/failure")
      failures.size.should == 1
      failures.first.attributes["type"].should =~ /ExpectationNotMetError/
    end

    it "should have one failure for the bad coder" do
      failures = @doc.root.elements.to_a("/testsuite/testcase[@name='Bad coder']/failure")
      failures.size.should == 1
      failures.first.attributes["type"].should == "RuntimeError"
    end
  end
end
