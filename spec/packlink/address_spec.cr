require "../spec_helper"

def test_address
  Packlink::Address.build({
    email:    "test@packlink.com",
    phone:    "630465777",
    name:     "TestName",
    surname:  "TestLastName",
    street1:  "Avenue Marchal 1",
    zip_code: "75001",
    city:     "Paris",
    country:  "FR",
    state:    "Paris",
  })
end

describe Packlink::Address do
  describe "getters" do
    it "has getters for the values" do
      address = test_address
      address.city.should eq("Paris")
      address.country.should eq("FR")
      address.email.should eq("test@packlink.com")
      address.name.should eq("TestName")
      address.phone.should eq("630465777")
      address.state.should eq("Paris")
      address.street1.should eq("Avenue Marchal 1")
      address.surname.should eq("TestLastName")
      address.zip_code.should eq("75001")
    end
  end

  describe "#to_h" do
    it "can be converted to a hash" do
      hash = test_address.to_h
      hash["city"].should eq("Paris")
      hash["country"].should eq("FR")
      hash["email"].should eq("test@packlink.com")
      hash["name"].should eq("TestName")
      hash["phone"].should eq("630465777")
      hash["state"].should eq("Paris")
      hash["street1"].should eq("Avenue Marchal 1")
      hash["surname"].should eq("TestLastName")
      hash["zip_code"].should eq("75001")
    end
  end
end
