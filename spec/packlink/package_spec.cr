require "../spec_helper"

def test_package
  Packlink::Package.new(40, 30.1, "20", 0.5)
end

describe Packlink::Package do
  describe "getters" do
    it "creates getters for the values" do
      test_package.width.should eq(40)
      test_package.height.should eq(30.1)
      test_package.length.should eq("20")
      test_package.weight.should eq(0.5)
    end
  end

  describe "#to_h" do
    it "can be converted to a hash" do
      hash = test_package.to_h
      hash["width"].should eq(40)
      hash["height"].should eq(30.1)
      hash["length"].should eq("20")
      hash["weight"].should eq(0.5)
    end
  end

  describe "#to_json" do
    it "can be converted to json" do
      json = test_package.to_json
      json.should match(/"width":40/)
      json.should match(/"height":30.1/)
      json.should match(/"length":"20"/)
      json.should match(/"weight":0.5/)
    end
  end
end
