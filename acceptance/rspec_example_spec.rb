describe "RSpec example" do
  it "should succeed" do
    true.should be_true
    nil.should be_nil
  end

  it "should fail" do
    violated
  end

  it "should be pending"

  describe "nested" do
    it "should succeed" do
      true.should be_true
    end
  end
end
