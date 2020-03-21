require "../spec_helper"

def test_list_json
  %({
    "items" : [
      { "name" : "Royal", "price" : 100.21 }
    ],
    "query" : {
      "key" : "value",
      "from" : { "country" : "BE", "zip" : 3000 },
      "packages" : {
        "0" : { "width": 10, "height" : "20", "length" : 10.5, "weight" : 0.5 }
      }
    },
    "params" : { "id" : 10021 }
  })
end

describe Packlink::List do
  describe ".from_json" do
    it "builds the list" do
      list = Packlink::List(Packlink::TestItem).from_json(test_list_json)
      list.size.should eq(1)
      list.first.name.should eq("Royal")
      list.first.price.should eq(100.21)
      list.params.should eq({"id" => 10021})
      list.query.should eq({
        "key"      => "value",
        "from"     => {"country" => "BE", "zip" => 3000},
        "packages" => {
          "0" => {"width" => 10, "height" => "20", "length" => 10.5, "weight" => 0.5},
        },
      })
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
