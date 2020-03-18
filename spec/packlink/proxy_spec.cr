require "../spec_helper"

def proxy_client
  Packlink::Client.new("proxy_in_a_sandbox")
end

def proxy_sandbox_headers
  {"Authorization" => "secret_proxy_key"}
end

def test_proxy
  Packlink::Proxy.new(proxy_client)
end

describe Packlink::Proxy do
  describe "#client" do
    it "returns the given client" do
      test_proxy.client.should eq(proxy_client)
    end
  end

  describe "#order" do
    it "returns a proxy object which sandboxes requests to the given client" do
      test_proxy.order.should be_a(Packlink::Proxy::Order)
      test_proxy.order.client.should eq(proxy_client)
    end

    # it "proxies all" do
    #   WebMock.stub(:get, "https://api.mollie.com/v2/payments")
    #     .with(headers: proxy_sandbox_headers)
    #     .to_return(body: read_fixture("payments/list.json"))

    #   payments = test_proxy.payment.all
    #   payments.should be_a(Packlink::List(Packlink::Payment))
    #   payments.first.id.should eq("tr_7UhSN1zuXS")
    # end

    # it "proxies get" do
    #   WebMock.stub(:get, "https://api.mollie.com/v2/payments/tr_WDqYK6vllg")
    #     .with(headers: proxy_sandbox_headers)
    #     .to_return(body: read_fixture("payments/get.json"))

    #   test_proxy.payment.get("tr_WDqYK6vllg").id.should eq("tr_WDqYK6vllg")
    # end

    # it "proxies create" do
    #   body = %({"amount":21.21,"currency":"GBP"})
    #   WebMock.stub(:post, "https://api.mollie.com/v2/payments")
    #     .with(body: body, headers: proxy_sandbox_headers)
    #     .to_return(body: read_fixture("payments/get.json"))

    #   payment = test_proxy.payment.create({
    #     amount:   21.21,
    #     currency: "GBP",
    #   })
    #   payment.id.should eq("tr_WDqYK6vllg")
    # end

    # it "proxies update" do
    #   body = %({"amount":12.12,"currency":"EUR"})
    #   WebMock.stub(:patch, "https://api.mollie.com/v2/payments/tr_WDqYK6vllg")
    #     .with(body: body, headers: proxy_sandbox_headers)
    #     .to_return(body: read_fixture("payments/get.json"))

    #   payment = test_proxy.payment.update("tr_WDqYK6vllg", {
    #     amount:   12.12,
    #     currency: "EUR",
    #   })
    #   payment.id.should eq("tr_WDqYK6vllg")
    # end

    # it "proxies delete" do
    #   WebMock.stub(:delete, "https://api.mollie.com/v2/payments/tr_WDqYK6vllg")
    #     .with(body: "{}", headers: proxy_sandbox_headers)
    #     .to_return(body: "")

    #   test_proxy.payment.delete("tr_WDqYK6vllg").should eq("")
    # end

    # it "proxies cancel" do
    #   WebMock.stub(:delete, "https://api.mollie.com/v2/payments/tr_WDqYK6vllg")
    #     .with(body: "{}", headers: proxy_sandbox_headers)
    #     .to_return(body: "")

    #   test_proxy.payment.cancel("tr_WDqYK6vllg").should eq("")
    # end
  end

  describe "#order" do
    it "returns a proxy object" do
      test_proxy.order.should be_a(Packlink::Proxy::Order)
    end
  end
end
