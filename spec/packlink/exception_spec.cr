require "../spec_helper"

def test_exception
  Packlink::RequestException.from_json(read_fixture("exceptions/unauthorized"))
end

def test_exception_with_messages
  Packlink::RequestException.from_json(read_fixture("exceptions/countries"))
end

describe Packlink::RequestException do
  describe "#initialize" do
    it "serializes json with a single message" do
      test_exception.to_s.should contain("The server could not verify")
    end

    it "serializes json with a multiple messages" do
      message = test_exception_with_messages.messages.as(Array).first
      message.should be_a(Packlink::ExceptionMessage)
      message.to_s.should eq("Country from and country to are required")
    end
  end
end
