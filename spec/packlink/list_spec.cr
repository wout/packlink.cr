require "../spec_helper"

def test_list_json
  %({"items":[{"name":"Royal","price":100.21}]})
end

describe Packlink::List do
  describe ".from_json" do
    it "builds the list" do
      list = Packlink::List(Packlink::TestItem).from_json(test_list_json)
      list.size.should eq(1)
      list.first.name.should eq("Royal")
      list.first.price.should eq(100.21)
    end
  end
end

struct Packlink
  struct TestItem
    JSON.mapping({
      name:  String,
      price: Float64,
    })
  end
end
