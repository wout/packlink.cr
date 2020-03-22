require "../spec_helper"

describe Packlink::Label do
  before_each do
    configure_test_api_key
  end

  describe ".all" do
    it "receives an array" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/ES00019388AB/labels")
        .to_return(body: read_fixture("labels/all-response"))

      labels = Packlink::Label.all({shipment_reference: "ES00019388AB"})
      labels.should be_a(Packlink::List(String))
      labels.size.should eq(1)
      labels.first.should contain("getLabelsByRef?ref=52cfc1a84")
    end

    it "accepts a shipment id" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/ES00019388AB/labels")
        .to_return(body: read_fixture("labels/all-response"))

      labels = Packlink::Label.all("ES00019388AB")
      labels.first.should contain("http://packlink.de/de/purchase/PostVenta")
      labels.first.should contain("getLabelsByRef?ref=52cfc1a8419a698247622")
    end
  end
end
