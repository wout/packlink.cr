require "../spec_helper"

describe Packlink::Callback do
  before_each do
    configure_test_api_key
  end

  describe ".create" do
    it "creates a callback" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/shipments/callback")
        .to_return(status: 201, body: "")

      Packlink::Callback.create({url: "http://www.urlexample.com"})
    end
  end

  describe ".register" do
    it "creates a callback" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/shipments/callback")
        .to_return(status: 201, body: "")

      Packlink::Callback.register("http://www.urlexample.com")
    end
  end
end

describe Packlink::Callback::Event do
  describe ".from_json" do
    it "parses the event" do
      event = Packlink::Callback::Event.from_json(read_fixture("callbacks/event"))
      event.name.should eq("shipment.carrier.success")
      event.datetime.should eq("2015-01-01 15:55:23")
      event.data.shipment_custom_reference.should eq("eBay_11993382332589")
      event.data.shipment_reference.should eq("DE567YH981230AA")
    end
  end

  describe "#created_at" do
    it "returns the parsed datetime value" do
      event = Packlink::Callback::Event.from_json(read_fixture("callbacks/event"))
      event.created_at.should eq(Time.parse_utc("2015-01-01 15:55:23", "%F %T"))
    end
  end
end
