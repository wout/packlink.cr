require "../spec_helper"

def test_exception
  Packlink::RequestException.from_json(read_fixture("exceptions/unauthorized"))
end

def test_exception_with_messages
  Packlink::RequestException.from_json(read_fixture("exceptions/countries"))
end

def test_exception_with_message_arrays
  Packlink::RequestException.from_json(read_fixture("exceptions/orders"))
end

describe Packlink::RequestException do
  describe "#initialize" do
    it "serializes json with a single message" do
      message = test_exception.exception_message.as(String)
      message.should contain("The server could not verify")
    end

    it "serializes json with multiple messages" do
      messages = test_exception_with_messages.exception_messages.as(Array)
      messages.first.should be_a(Packlink::ExceptionMessage)
      messages.first.message.should eq("Country from and country to are required")
      messages.last.should be_a(Packlink::ExceptionMessage)
      messages.last.message.should eq("Country is not allowed")
    end

    it "serializes json with multiple message arrays" do
      messages = test_exception_with_message_arrays.exception_messages.as(Array)
      messages.first.should be_a(Packlink::ExceptionMessage)
      messages.first.message.should contain("Shipment eBay_11993382332:")
      messages.first.message.should contain("Service not available for this user")
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
      message.should contain("Country is not allowed")
    end

    it "returns the multiple message arrays as a sentence" do
      message = test_exception_with_message_arrays.message
      message.should contain("Shipment eBay_11993382332:")
      message.should contain("Service not available for this user")
      message.should contain("It's your fault!")
      message.should contain("I need to say this...")
    end
  end
end
