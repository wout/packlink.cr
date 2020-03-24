require "../spec_helper"

def proxy_client
  Packlink::Client.new("secret_proxy_key")
end

def proxy_headers
  {"Authorization" => "secret_proxy_key"}
end

def test_proxy
  Packlink::Proxy.new(proxy_client)
end

def test_proxy_package
  Packlink::Package.build({
    width:  10,
    height: 10,
    length: 10,
    weight: 1,
  })
end

describe Packlink::Proxy do
  describe "#client" do
    it "returns the given client" do
      test_proxy.client.should eq(proxy_client)
    end
  end

  describe "#callback" do
    it "proxies #register" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/shipments/callback")
        .to_return(body: "")

      test_proxy.callback.register(20154)
    end
  end

  describe "#customs" do
    it "proxies #pdf" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/DE2015API0000003515/customs")
        .to_return(body: read_fixture("customs/get-response"))

      test_proxy.customs.pdf("DE2015API0000003515")
    end
  end

  describe "#draft" do
    it "proxies #create" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/shipments")
        .with(body: %({"content":"Test content"}))
        .to_return(body: read_fixture("drafts/post-response"))

      test_proxy.draft.create({
        content: "Test content",
      })
    end
  end

  describe "#dropoff" do
    it "proxies #all" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/dropoffs/21369/GB/BN2 1JJ")
        .to_return(body: read_fixture("dropoffs/all-response"))

      test_proxy.dropoff.all({
        service_id: 21369,
        country:    "GB",
        zip:        "BN2 1JJ",
      })
    end
  end

  describe "#label" do
    it "proxies #all" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/ES00019388AB/labels")
        .to_return(body: read_fixture("labels/all-response"))

      test_proxy.label.all("ES00019388AB")
    end
  end

  describe "#order" do
    it "proxies #create" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/orders")
        .to_return(body: read_fixture("orders/post-response"))

      test_proxy.order.create({
        order_custom_reference: "Beautiful leggins from eBay",
        shipment:               [] of Packlink::Order::Shipment,
      })
    end
  end

  describe "#service" do
    it "proxies #find" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services/available/20154/details")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/get-response"))

      test_proxy.service.find(20154)
    end

    it "proxies #from" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=GB&from[zip]=BN2+1JJ&to[country]=BE&to[zip]=3000&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .from("GB", "BN2 1JJ")
        .to("BE", 3000)
        .package(test_proxy_package).all
    end

    it "proxies #to" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?to[country]=GB&to[zip]=BN2+1JJ&from[country]=BE&from[zip]=3000&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .to("GB", "BN2 1JJ")
        .from("BE", 3000)
        .package(test_proxy_package).all
    end

    it "proxies #package" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=BE&from[zip]=1000&to[country]=GB&to[zip]=BN2+1JJ&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .package(test_proxy_package)
        .from("BE", 1000)
        .to("GB", "BN2 1JJ").all
    end
  end

  describe "#shipment" do
    it "proxies #find" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/DE2015API0000003515")
        .to_return(body: read_fixture("shipments/get-response"))

      test_proxy.shipment.find("DE2015API0000003515")
    end
  end

  describe "#tracking" do
    it "proxies #history" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/ES00019388AB/track")
        .to_return(body: read_fixture("tracking/get-response"))

      test_proxy.tracking.history("ES00019388AB")
    end
  end
end
