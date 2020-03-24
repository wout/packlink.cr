require "../spec_helper"

describe Packlink::Tracking do
  before_each do
    configure_test_api_key
  end

  describe ".find" do
    it "fetches the history for a given shipment reference" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/ES00019388AB/track")
        .to_return(body: read_fixture("tracking/get-response"))

      tracking = Packlink::Tracking.find({shipment_reference: "ES00019388AB"})
      tracking.history.should be_a(Array(Packlink::Tracking::Event))
      event = tracking.history.first
      event.city.should eq("MIAMI")
      event.created_at.should eq(Time.unix(event.timestamp * 100))
      event.description.should eq("DELIVERED")
      event.timestamp.should eq(14242322)
    end
  end

  describe ".history" do
    it "returns the history directly" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/ES00019388AB/track")
        .to_return(body: read_fixture("tracking/get-response"))

      history = Packlink::Tracking.history("ES00019388AB")
      history.should be_a(Array(Packlink::Tracking::Event))
      history.first.description.should eq("DELIVERED")
    end
  end
end
