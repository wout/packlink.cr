require "../spec_helper"

describe Packlink::Package do
  describe "getters" do
    it "creates getters for the values" do
      package = Packlink::Package.new(40, 30.1, "20", 0.5)
      package.width.should eq(40)
      package.height.should eq(30.1)
      package.length.should eq("20")
      package.weight.should eq(0.5)
    end
  end

  describe "#to_h" do
    it "can be converted to a hash" do
      hash = Packlink::Package.new(40, 30, 20, 5).to_h
      hash["width"].should eq(40)
      hash["height"].should eq(30)
      hash["length"].should eq(20)
      hash["weight"].should eq(5)
    end
  end

  describe "#to_json" do
    it "can be converted to json" do
      json = Packlink::Package.new(40, 30, 20, 5).to_json
      json.should match(/"width":40/)
      json.should match(/"height":30/)
      json.should match(/"length":20/)
      json.should match(/"weight":5/)
    end
  end
end
