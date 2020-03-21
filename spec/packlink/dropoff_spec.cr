require "../spec_helper"

describe Packlink::Dropoff do
  before_each do
    configure_test_api_key
  end

  describe ".find" do
    it "finds a series of dropoff points" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/dropoffs/21369/GB/BN2 1JJ")
        .to_return(status: 200, body: read_fixture("dropoffs/all-response"))

      dropoffs = Packlink::Dropoff.all({
        service_id: 21369,
        country:    "GB",
        zip:        "BN2 1JJ",
      })

      dropoff = dropoffs.first

      dropoff.address.should eq("52 St. George's Road")
      dropoff.city.should eq("Brighton")
      dropoff.commerce_name.should eq("St. Georges News")
      dropoff.country.should be_nil
      dropoff.id.should eq("S16271")
      dropoff.lat.should eq(BigDecimal.new("50.817563999999997"))
      dropoff.long.should eq(BigDecimal.new("-0.118057"))
      dropoff.opening_times.should be_a(Packlink::Dropoff::OpeningTimes)
      dropoff.opening_times.monday.should eq("06:00-21:00")
      dropoff.opening_times.tuesday.should eq("06:00-21:00")
      dropoff.opening_times.wednesday.should eq("06:00-21:00")
      dropoff.opening_times.thursday.should eq("06:00-21:00")
      dropoff.opening_times.friday.should eq("06:00-21:00")
      dropoff.opening_times.saturday.should eq("06:00-21:00")
      dropoff.opening_times.sunday.should eq("06:00-21:00")
      dropoff.phone.should eq("07461451073")
      dropoff.state.should be_nil
      dropoff.type.should eq("")
      dropoff.zip.should eq("BN2 1EF")
    end
  end
end
