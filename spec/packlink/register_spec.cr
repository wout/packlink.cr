require "../spec_helper"

def test_registration
  Packlink::Register.from_json(read_fixture("registrations/post-response"))
end

describe Packlink::Register do
  before_each do
    configure_test_api_key
  end

  describe ".create" do
    it "registers a user" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .to_return(body: read_fixture("registrations/post-response"))

      response = Packlink::Register.create({
        email:                     "myaccount@packlink.es",
        estimated_delivery_volume: "1 - 10",
        ip:                        "123.123.123.123",
        password:                  "myPassword",
        phone:                     "+34666558877",
        platform:                  "PRO",
        platform_country:          "ES",
        policies:                  {
          terms_and_conditions: true,
          data_processing:      true,
          marketing_emails:     true,
          marketing_calls:      true,
        },
        referral: {
          onboarding_product:     "dummy",
          onboarding_sub_product: "sub_dummy",
        },
        source: "https://urlwhereregistrationoffered",
      })
      response.should be_a(Packlink::Register::CreatedResponse)
      response.token.should eq("de1badc159485f880000c954ebf26795a70b5fdf6433875488358e6496c566c4")
    end

    it "can not register a user twice" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .to_return(status: 400, body: read_fixture("registrations/post-400"))

      expect_raises(Packlink::RequestException) do
        Packlink::Register.create({
          email: "myaccount@packlink.es",
        })
      end
    end
  end

  describe ".user" do
    it "immediately returns the token" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .to_return(body: read_fixture("registrations/post-response"))

      token = Packlink::Register.user({
        email:                     "myaccount@packlink.es",
        estimated_delivery_volume: "1 - 10",
        ip:                        "123.123.123.123",
        password:                  "myPassword",
        phone:                     "+34666558877",
        platform:                  "PRO",
        platform_country:          "ES",
        policies:                  {
          terms_and_conditions: true,
          data_processing:      true,
          marketing_emails:     true,
          marketing_calls:      true,
        },
        referral: {
          onboarding_product:     "dummy",
          onboarding_sub_product: "sub_dummy",
        },
        source: "https://urlwhereregistrationoffered",
      })
      token.should eq("de1badc159485f880000c954ebf26795a70b5fdf6433875488358e6496c566c4")
    end
  end
end
