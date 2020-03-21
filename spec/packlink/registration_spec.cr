require "../spec_helper"

def test_registration
  Packlink::Registration.from_json(read_fixture("registrations/post-response"))
end

describe Packlink::Registration do
  before_each do
    configure_test_api_key
  end

  describe ".create" do
    it "registers a user" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .to_return(body: read_fixture("registrations/post-response"))

      response = Packlink::Registration.create({
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
      response.should be_a(Packlink::Registration::CreatedResponse)
      response.token.should eq("de1badc159485f880000c954ebf26795a70b5fdf6433875488358e6496c566c4")
    end

    it "can not register a user twice" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/register")
        .to_return(status: 400, body: read_fixture("registrations/post-400"))

      expect_raises(Packlink::RequestException) do
        Packlink::Registration.create({
          email: "myaccount@packlink.es",
        })
      end
    end
  end
end
