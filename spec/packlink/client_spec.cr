require "../spec_helper"

def test_client
  Packlink::Client.new("secret_key")
end

def production_endpoint(path = "")
  "https://api.packlink.com#{path}"
end

def sandbox_endpoint(path = "")
  "https://apisandbox.packlink.com#{path}"
end

describe Packlink::Client do
  describe "#initialize" do
    it "stores the api key" do
      test_client.api_key.should eq("secret_key")
    end

    it "falls back to the globally configured api key" do
      Packlink::Config.api_key = "my_key"
      Packlink::Client.new.api_key.should eq("my_key")
    end

    it "fails if no api key is provided" do
      expect_raises(Packlink::MissingApiKeyException) do
        Packlink::Client.new
      end
    end
  end

  describe "#endpoint" do
    it "returns the production endpoint in production" do
      Packlink::Config.environment = "production"
      test_client.endpoint.should eq(production_endpoint)
    end

    it "returns the sandbox endpoint in sandbox" do
      Packlink::Config.environment = "sandbox"
      test_client.endpoint.should eq(sandbox_endpoint)
    end
  end

  describe "#api_path" do
    it "prepends the api version" do
      test_client.api_path("my-method")
        .should eq("/v1/my-method")
    end

    it "accepts a full api uri" do
      test_client.api_path(sandbox_endpoint("/v1/my-method"))
        .should eq("/v1/my-method")
    end
  end

  describe "#perform_http_call" do
    it "fails with an invalid http method" do
      expect_raises(Packlink::MethodNotSupportedException) do
        test_client.perform_http_call("PUT", "my-method")
      end
    end

    it "has defaults to be able to perform a request" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/my-method")
        .with(headers: {"Authorization" => "secret_key"})
        .to_return(status: 200, body: "{}")

      test_client.perform_http_call("GET", "my-method")
    end

    it "accepts additional headers" do
      auth_headers = {
        "Authorization" => "Basic bXlhY2NvdW50QHBhY2tsaW5rLmVzOm15UGFzc3dvcmQ=",
      }
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/auth-method")
        .with(headers: auth_headers)
        .to_return(body: "")

      test_client.perform_http_call("GET", "auth-method", headers: auth_headers)
    end

    it "returns a raw json string for successful requests" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/good")
        .to_return(status: 200, body: %({"ip": "0.0.0.0"}))

      response = test_client.perform_http_call("GET", "good")
      json = JSON.parse(response)
      json["ip"].should eq("0.0.0.0")
    end

    it "returns an empty string for a response without content" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/empty")
        .to_return(status: 204)

      response = test_client.perform_http_call("GET", "empty")
      response.should eq("")
    end

    it "raises a request exception for an unauthorized error" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/unauthorized")
        .to_return(status: 401, body: read_fixture("exceptions/unauthorized"))

      expect_raises(Packlink::RequestException) do
        test_client.perform_http_call("POST", "unauthorized")
      end
    end

    it "raises a request exception for a not found error" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/missing")
        .to_return(status: 404)

      expect_raises(Packlink::RequestException) do
        test_client.perform_http_call("POST", "missing")
      end
    end

    it "raises a request exception for a server error" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/error")
        .to_return(status: 500, body: read_fixture("exceptions/countries"))

      expect_raises(Packlink::RequestException) do
        test_client.perform_http_call("POST", "error")
      end
    end
  end

  describe "#get" do
    it "fetches a resource" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/order")
        .to_return(status: 200, body: "{}")

      test_client.get("order").should eq("{}")
    end

    it "optionally accepts query params" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/order?some=stone")
        .to_return(status: 200, body: "{}")

      test_client.get("order", {some: "stone"}).should eq("{}")
    end

    it "optionally accepts headers" do
      headers = {"Auth" => "Secret"}
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/order")
        .with(headers: headers)
        .to_return(status: 200, body: "{}")

      test_client.get("order", headers: headers).should eq("{}")
    end
  end

  describe "#post" do
    it "creates a resource" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/orders")
        .to_return(status: 200, body: "{}")

      test_client.post("orders", {id: "65423"}).should eq("{}")
    end

    it "optionally accepts query params" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/order?some=stone")
        .to_return(status: 200, body: "{}")

      test_client.post("order", {id: "65423"}, query: {some: "stone"}).should eq("{}")
    end

    it "optionally accepts headers" do
      headers = {"Auth" => "Secret"}
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/orders")
        .with(headers: headers)
        .to_return(status: 200, body: "{}")

      test_client.post("orders", {id: "123"}, headers: headers).should eq("{}")
    end
  end

  describe ".instance" do
    it "returns a new instance" do
      Packlink::Config.api_key = "my_key"
      Packlink::Client.instance.should be_a(Packlink::Client)
    end

    it "never initializes another new instance" do
      Packlink::Config.api_key = "my_key"
      instance = Packlink::Client.instance
      Packlink::Client.instance.should eq(instance)
    end
  end

  describe ".with_api_key" do
    context "without a block" do
      it "returns the instance for a given api key" do
        client_1 = Packlink::Client.new("key_1")
        client_2 = Packlink::Client.new("key_2")
        Packlink::Client.with_api_key("key_1").should eq(client_1)
        Packlink::Client.with_api_key("key_2").should eq(client_2)
      end

      it "never initializes another instance for the given api key" do
        client = Packlink::Client.with_api_key("mastaba")
        Packlink::Client.with_api_key("mastaba").should eq(client)
      end
    end

    context "with a block" do
      it "can be invoked" do
        Packlink::Client.with_api_key("key_3") do |packlink|
          packlink.should be_a(Packlink::Proxy)
          packlink.client.should eq(Packlink::Client.with_api_key("key_3"))
        end
      end

      it "will use the same api key for all calls within a block" do
        WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
          .with(headers: {"Authorization" => "first_key"})
          .to_return(body: read_fixture("registrations/post-response"))

        Packlink::Client.with_api_key("first_key") do |packlink|
          packlink.registration.create({email: "a@b.c"})
            .should be_a(Packlink::Registration::CreatedResponse)
          # packlink.refund.get("first_refund").should be_a(Packlink::Refund)
        end

        Packlink::Client.with_api_key("another_key") do |packlink|
          packlink
          # packlink.payment.get("another_payment").should be_a(Packlink::Payment)
          # packlink.profile.get("another_profile").should be_a(Packlink::Profile)
        end
      end
    end
  end
end

struct Packlink
  struct ClientPath
    getter pattern = "client/path"
  end
end
