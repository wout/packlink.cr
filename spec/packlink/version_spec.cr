require "../spec_helper.cr"

describe Packlink::VERSION do
  it "returns the current version" do
    Packlink::VERSION.should eq(`git describe --abbrev=0 --tags`.strip)
  end
end
