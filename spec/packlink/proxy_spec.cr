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

describe Packlink::Proxy do
  describe "#client" do
    it "returns the given client" do
      test_proxy.client.should eq(proxy_client)
    end
  end

  describe "#registration" do
    it "proxies create" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .with(headers: proxy_headers)
        .to_return(body: read_fixture("registrations/post-response"))

      response = test_proxy.registration.create({
        email:                     "myaccount@packlink.es",
        estimated_delivery_volume: "1 - 10",
        ip:                        "123.123.123.123",
      })
      response.should be_a(Packlink::Registration::Response)
    end

    it "returns a proxy object" do
      test_proxy.registration.should be_a(Packlink::Proxy::Registration)
    end
  end
end
