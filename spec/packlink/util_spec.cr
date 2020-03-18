require "../spec_helper"

describe Packlink::Util do
  describe ".build_nested_query" do
    context "given a hash" do
      it "returns a query param string" do
        query = Packlink::Util.build_nested_query({
          :name  => "Aap",
          :email => "noot@mies.wim",
        })
        query.should eq("name=Aap&email=noot%40mies.wim")
      end

      it "returns prefixed query param string" do
        query = Packlink::Util.build_nested_query({
          :name  => "Aap",
          :email => "noot@mies.wim",
        }, "zus")
        query.should eq("zus[name]=Aap&zus[email]=noot%40mies.wim")
      end

      it "accepts arrays as values" do
        query = Packlink::Util.build_nested_query({
          :name => "Aap",
          :list => %w[noot mies],
        }, "wim")
        query.should eq("wim[name]=Aap&wim[list][]=noot&wim[list][]=mies")
      end

      it "accepts arrays with hashes" do
        query = Packlink::Util.build_nested_query({
          :name => "Aap",
          :list => [{:noot => "mies", :wim => 205}],
        }, "jet")
        query.should eq("jet[name]=Aap&jet[list][][noot]=mies&jet[list][][wim]=205")
      end
    end

    context "given a named tuple" do
      it "returns a query param string" do
        query = Packlink::Util.build_nested_query({
          name:  "Aap",
          email: "noot@mies.wim",
        })
        query.should eq("name=Aap&email=noot%40mies.wim")
      end

      it "returns prefixed query param string" do
        query = Packlink::Util.build_nested_query({
          name:  "Aap",
          email: "noot@mies.wim",
        }, "zus")
        query.should eq("zus[name]=Aap&zus[email]=noot%40mies.wim")
      end

      it "accepts arrays as values" do
        query = Packlink::Util.build_nested_query({
          name: "Aap",
          list: %w[noot mies],
        }, "wim")
        query.should eq("wim[name]=Aap&wim[list][]=noot&wim[list][]=mies")
      end
    end

    context "given an array" do
      it "returns a query param string" do
        query = Packlink::Util.build_nested_query(%w[aap noot mies])
        query.should eq("[]=aap&[]=noot&[]=mies")
      end

      it "returns prefixed query param string" do
        query = Packlink::Util.build_nested_query(%w[aap noot mies], "zus")
        query.should eq("zus[]=aap&zus[]=noot&zus[]=mies")
      end
    end

    context "given a string" do
      it "returns a query param string" do
        query = Packlink::Util.build_nested_query("aap", "noot")
        query.should eq("noot=aap")
      end
    end

    context "given nil" do
      it "returns nil" do
        query = Packlink::Util.build_nested_query(nil)
        query.should be_nil
      end

      it "returns the prefix" do
        query = Packlink::Util.build_nested_query(nil, "aap")
        query.should eq("aap")
      end
    end
  end
end
