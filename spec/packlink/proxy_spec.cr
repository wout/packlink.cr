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

  describe "#auth" do
    it "proxies login" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/login")
        .with(headers: {
          "Authorization" => "Basic bXlhY2NvdW50QHBhY2tsaW5rLmVzOm1hc3RhYmE=",
        })
        .to_return(body: read_fixture("logins/get-response"))

      response = test_proxy.auth.login({
        email:    "myaccount@packlink.es",
        password: "mastaba",
      })
      response.should be_a(Packlink::Auth::Resource)
    end

    it "returns a proxy object" do
      test_proxy.auth.should be_a(Packlink::Proxy::Auth)
    end
  end
end
