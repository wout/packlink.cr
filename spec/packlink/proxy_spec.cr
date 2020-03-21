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
      response.should be_a(Packlink::Registration::CreatedResponse)
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
      response.should be_a(Packlink::Auth::FoundResponse)
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

      response = test_proxy.user.verify("currently_stored_key")
      response.should be_a(Packlink::User::FoundResponse)
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

      response = test_proxy.user.activate("currently_stored_key")
      response.should be_a(Packlink::User::CreatedResponse)
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
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=GB&from[zip]=BN2+1JJ&to[country]=BE&to[zip]=3000&packages[0][width]=30&packages[0][height]=30&packages[0][length]=30&packages[0][weight]=3")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .from("GB", "BN2 1JJ")
        .to("BE", 3000)
        .package(30, 30, 30, 3).all
    end

    it "proxies to" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?to[country]=GB&to[zip]=BN2+1JJ&from[country]=BE&from[zip]=3000&packages[0][width]=20&packages[0][height]=20&packages[0][length]=20&packages[0][weight]=2")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .to("GB", "BN2 1JJ")
        .from("BE", 3000)
        .package(20, 20, 20, 2).all
    end

    it "proxies package" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=BE&from[zip]=1000&to[country]=GB&to[zip]=BN2+1JJ&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .with(headers: {"Authorization" => "secret_proxy_key"})
        .to_return(body: read_fixture("services/all-response"))

      test_proxy.service
        .package(10, 10, 10, 1)
        .from("BE", 1000)
        .to("GB", "BN2 1JJ").all
    end
  end
end
