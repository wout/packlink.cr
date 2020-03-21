require "../spec_helper"

def test_auth
  Packlink::Auth.from_json(read_fixture("logins/post-response"))
end

describe Packlink::Auth do
  before_each do
    configure_test_api_key
  end

  describe ".login" do
    it "logs in a user" do
      headers = {
        "Authorization" => "Basic bXlhY2NvdW50QHBhY2tsaW5rLmVzOm15UGFzc3dvcmQ=",
      }
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/login?platform=pro&platform_country=gb")
        .with(headers: headers)
        .to_return(body: read_fixture("logins/get-response"))

      response = Packlink::Auth.login({
        email:            "myaccount@packlink.es",
        password:         "myPassword",
        platform:         "pro",
        platform_country: "gb",
      })
      response.should be_a(Packlink::Auth::FoundResponse)
      response.token.should eq("44c2a45734386ca1ff9a77a6f82cd4f20962c094835f1f6d6ba8c7ef94b0a155")
    end

    it "accepts a client to perform the request" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/login")
        .with(headers: {"Authorization" => "Basic YUBiLmM6ZA=="})
        .to_return(body: read_fixture("logins/get-response"))

      Packlink::Auth.login(
        {email: "a@b.c", password: "d"},
        client: Packlink::Client.new("my_key"))
    end

    it "fails if email and/or password are not provided" do
      expect_raises(Packlink::AuthCredentialsMissingException) do
        Packlink::Auth.login({platform: "pro"})
      end
    end

    it "fails if the login credentials are incorrect" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/login")
        .with(headers: {"Authorization" => "Basic YUBiLmM6c1VNdElOR3dPTkc="})
        .to_return(status: 401, body: read_fixture("logins/get-401"))

      expect_raises(Packlink::RequestException) do
        Packlink::Auth.login({email: "a@b.c", password: "sUMtINGwONG"})
      end
    end
  end

  describe ".password_reset" do
    it "requests a password reset link" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/users/recover-password/notify?platform=pro&platform_country=gb")
        .with(body: %({"email":"myaccount@packlink.es"}))
        .to_return(body: "")

      response = Packlink::Auth.reset_password({
        email:            "myaccount@packlink.es",
        platform:         "pro",
        platform_country: "gb",
      })
      response.should be_a(Packlink::Auth::CreatedResponse)
    end

    it "fails if email is not provided" do
      expect_raises(Packlink::AuthCredentialsMissingException) do
        Packlink::Auth.reset_password({platform: "pro"})
      end
    end
  end

  describe ".encoded_auth_header" do
    it "generates a string for login authentication" do
      auth_string = Packlink::Auth.encoded_auth_header(
        "myaccount@packlink.es", "myPassword")
      auth_string.should eq("Basic bXlhY2NvdW50QHBhY2tsaW5rLmVzOm15UGFzc3dvcmQ=")
    end
  end
end
