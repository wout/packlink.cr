require "../spec_helper"

describe Packlink::Customs do
  before_each do
    configure_test_api_key
  end

  describe ".find" do
    it "fetches the customs documentation" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/DE2015API0000003515/customs")
        .to_return(body: read_fixture("customs/get-response"))

      document = Packlink::Customs.find({shipment_reference: "DE2015API0000003515"})
      document.url.should contain("http://static.packitos.com/prodev-pro/customs")
      document.url.should contain("/c24a19d1bf25df88abcd9145b562c58e932456b5.pdf")
    end
  end

  describe ".pdf" do
    it "fetches the customs documentation" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/DE2015API0000003515/customs")
        .to_return(body: read_fixture("customs/get-response"))

      pdf = Packlink::Customs.pdf("DE2015API0000003515")
      pdf.should contain("http://static.packitos.com/prodev-pro/customs")
      pdf.should contain("/c24a19d1bf25df88abcd9145b562c58e932456b5.pdf")
    end
  end
end
