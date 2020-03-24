require "../spec_helper"

def test_token
  "c80cfc01d13504e8a8cbe37ad2ea4e6f3464e388b7f56c7104724b4f5d557262"
end

def test_token_other
  "44c2a45734386ca1ff9a77a6f82cd4f20962c094835f1f6d6ba8c7ef94b0a155"
end

describe Packlink::User do
  describe ".verify" do
    it "returns the current api key if it is active" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => test_token})
        .to_return(status: 200, body: read_fixture("users/post-response"))

      token = Packlink::User.verify(test_token)
      token.should eq(test_token)
    end

    it "raises a 404 if the user is nog activated yet" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => test_token})
        .to_return(status: 404, body: read_fixture("users/get-404"))

      expect_raises(Packlink::ResourceNotFoundException) do
        Packlink::User.verify(test_token)
      end
    end
  end

  describe ".active?" do
    it "tests positive if the key is already activated" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => test_token})
        .to_return(status: 200, body: read_fixture("users/post-response"))

      active = Packlink::User.active?(test_token)
      active.should be_true
    end

    it "tests negative if the key is not activated" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => test_token})
        .to_return(status: 404, body: read_fixture("users/get-404"))

      active = Packlink::User.active?(test_token)
      active.should be_false
    end
  end

  describe ".activate" do
    it "creates a new api key" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => test_token_other})
        .to_return(status: 201, body: read_fixture("users/post-response"))

      token = Packlink::User.activate(test_token_other)
      token.should eq(test_token)
    end

    it "can not activate the same user twice" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/users/api/keys")
        .with(headers: {"Authorization" => test_token_other})
        .to_return(status: 400, body: read_fixture("users/post-400"))

      expect_raises(Packlink::RequestException) do
        Packlink::User.activate(test_token_other)
      end
    end
  end
end
