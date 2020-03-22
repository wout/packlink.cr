require "../spec_helper"

def test_package
  Packlink::Package.build({
    width:  40,
    height: 30.1,
    length: "20",
    weight: 0.5,
  })
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
      hash.should be_a(Hash(String, Packlink::A::Measurement))
      hash["width"].should eq(40)
      hash["height"].should eq(30.1)
      hash["length"].should eq("20")
      hash["weight"].should eq(0.5)
    end
  end

  describe "#to_json" do
    it "can be converted to json" do
      test_package.to_json.should be_a(String)
    end
  end
end
