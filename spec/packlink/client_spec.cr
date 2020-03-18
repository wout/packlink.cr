require "../spec_helper"

def test_client
  Packlink::Client.new("secret_key")
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
      test_client.endpoint.should eq("https://api.packlink.com")
    end

    it "returns the sandbox endpoint in sandbox" do
      Packlink::Config.environment = "sandbox"
      test_client.endpoint.should eq("https://apisandbox.packlink.com")
    end
  end

  describe "#perform_http_call" do
    it "fails with an invalid http method" do
      expect_raises(Packlink::MethodNotSupportedException) do
        test_client.perform_http_call("PUT", "my-method")
      end
    end
  end
end
