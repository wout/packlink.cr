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
      message = test_exception.exception_message.as(String)
      message.should contain("The server could not verify")
    end

    it "serializes json with a multiple messages" do
      messages = test_exception_with_messages.exception_messages.as(Array)
      messages.first.should be_a(Packlink::ExceptionMessage)
      messages.first.message.should eq("Country from and country to are required")
      messages.last.should be_a(Packlink::ExceptionMessage)
      messages.last.message.should eq("Country is not allowed")
    end
  end

  describe "#message" do
    it "returns the simgle message" do
      message = test_exception.message
      message.should contain("The server could not verify")
    end

    it "returns the multiple messages as a sentence" do
      message = test_exception_with_messages.message
      message.should contain("Country from and country to are required, ")
      message.should contain("country is not allowed")
    end
  end
end
