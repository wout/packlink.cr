require "../spec_helper"

describe Packlink::Path do
  describe "#to_s" do
    context "without params" do
      it "converts to a path" do
        path = Packlink::TestPath.new
        path.to_s.should eq("test/path")
      end
    end

    context "with params" do
      it "interpolates the given params" do
        path = Packlink::TestPathWithParams.new({
          with:   "aap",
          params: "noot",
        })
        path.to_s.should eq("test/path/aap/noot")
      end

      it "fails if not all required params are provided" do
        expect_raises(Packlink::ParamsMissingException) do
          Packlink::TestPathWithParams.new({
            params: "noot",
          }).to_s
        end
      end
    end
  end
end

struct Packlink
  struct TestPath < Packlink::Path
    getter pattern = "test/path"
  end

  struct TestPathWithParams < Packlink::Path
    getter pattern = "test/path/:with/:params"
  end
end
