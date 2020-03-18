require "./spec_helper"

describe Packlink do
  describe ".configure" do
    it "changes global the confguration" do
      Packlink.configure do |config|
        config.api_key = "my_key"
        config.open_timeout = 1.5
        config.read_timeout = 2.5
        config.environment = "sandbox"
      end

      Packlink::Config.api_key.should eq("my_key")
      Packlink::Config.open_timeout.should eq(1.5)
      Packlink::Config.read_timeout.should eq(2.5)
      Packlink::Config.environment.should eq("sandbox")
    end
  end
end
