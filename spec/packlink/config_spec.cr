require "../spec_helper"

describe Packlink::Config do
  describe ".api_key" do
    it "has no default api key" do
      Packlink::Config.api_key.should be_nil
    end
  end

  describe ".open_timeout" do
    it "has a default open timeout" do
      Packlink::Config.open_timeout.should eq(60)
    end
  end

  describe ".read_timeout" do
    it "has a default read timeout" do
      Packlink::Config.read_timeout.should eq(60)
    end
  end

  describe ".environment" do
    it "has a default environment" do
      Packlink::Config.environment.should eq("sandbox")
    end
  end

  describe ".environment=" do
    it "accepts sandbox and production" do
      Packlink::Config.environment = "sandbox"
      Packlink::Config.environment = "production"
    end

    it "fails if an invalid environment is given" do
      expect_raises(Packlink::InvalidEnvironmentException) do
        Packlink::Config.environment = "mastaba"
      end
    end
  end

  describe ".production?" do
    it "tests positive in production" do
      Packlink::Config.environment = "production"
      Packlink::Config.sandbox?.should be_false
      Packlink::Config.production?.should be_true
    end
  end

  describe ".sandbox?" do
    it "tests positive in sandbox" do
      Packlink::Config.environment = "sandbox"
      Packlink::Config.production?.should be_false
      Packlink::Config.sandbox?.should be_true
    end
  end
end
