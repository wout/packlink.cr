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

  describe "#register" do
    it "proxies create" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .with(headers: proxy_headers)
        .to_return(body: read_fixture("registrations/post-response"))

      token = test_proxy.register.user({
        email:                     "myaccount@packlink.es",
        estimated_delivery_volume: "1 - 10",
        ip:                        "123.123.123.123",
      })
      token.should be_a(String)
    end

    it "returns a proxy object" do
      test_proxy.register.should be_a(Packlink::Proxy::Register)
    end
  end

  describe "#auth" do
    it "proxies login" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/login")
        .with(headers: {
          "Authorization" => "Basic bXlhY2NvdW50QHBhY2tsaW5rLmVzOm1hc3RhYmE=",
        })
        .to_return(body: read_fixture("logins/get-response"))

      token = test_proxy.auth.login({
        email:    "myaccount@packlink.es",
        password: "mastaba",
      })
      token.should be_a(String)
    end

    it "returns a proxy object" do
      test_proxy.auth.should be_a(Packlink::Proxy::Auth)
    end
  end

  describe "#user" do
    it "proxies verify" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => "currently_stored_key"})
        .to_return(body: read_fixture("users/post-response"))

      token = test_proxy.user.verify("currently_stored_key")
      token.should be_a(String)
    end

    it "verifies validity of the api key" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/users/api/keys")
        .to_return(body: read_fixture("users/post-response"))

      test_proxy.user.active?("my_current_key").should be_a(Bool)
    end

    it "proxies activate" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => "currently_stored_key"})
        .to_return(body: read_fixture("users/post-response"))

      token = test_proxy.user.activate("currently_stored_key")
      token.should be_a(String)
    end

    it "returns a proxy object" do
      test_proxy.user.should be_a(Packlink::Proxy::User)
    end
  end

  describe "#service" do
    it "proxies find" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services/available/20154/details")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/get-response"))

      test_proxy.service.find({id: 20154})
    end

    it "proxies from" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=GB&from[zip]=BN2+1JJ&to[country]=BE&to[zip]=3000&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .from("GB", "BN2 1JJ")
        .to("BE", 3000)
        .package(test_proxy_package).all
    end

    it "proxies to" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?to[country]=GB&to[zip]=BN2+1JJ&from[country]=BE&from[zip]=3000&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .to("GB", "BN2 1JJ")
        .from("BE", 3000)
        .package(test_proxy_package).all
    end

    it "proxies package" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=BE&from[zip]=1000&to[country]=GB&to[zip]=BN2+1JJ&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .package(test_proxy_package)
        .from("BE", 1000)
        .to("GB", "BN2 1JJ").all
    end
  end
end
