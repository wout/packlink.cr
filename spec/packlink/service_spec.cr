require "../spec_helper"

def test_service
  Packlink::Service.from_json(read_fixture("services/all-response"))
end

describe Packlink::Service do
  before_each do
    configure_test_api_key
  end

  describe ".all" do
    it "fetches all available services" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=DE&from[zip]=56457&to[country]=DE&to[zip]=56457&packages[0][width]=10&packages[0][height]=10&packages[0][length]=10&packages[0][weight]=1")
        .to_return(body: read_fixture("services/all-response"))

      response = Packlink::Service.all(query: {
        from:     {country: "DE", zip: 56457},
        to:       {country: "DE", zip: 56457},
        packages: {
          "0": {width: 10, height: 10, length: 10, weight: 1},
        },
      })
      response.should be_a(Packlink::List(Packlink::Service::Item))
      item = response.items.first
      item.available_dates.should be_a(Hash(String, Packlink::Service::Hours))
      item.available_dates.size.should eq(12)
      item.available_dates["2020/03/30"].should be_a(Packlink::Service::Hours)
      item.available_dates["2020/03/30"].closed_at.should eq("18:00")
      item.available_dates["2020/03/30"].open_at.should eq("08:00")
      item.available_dates["2020/03/30"].to_s.should eq("08:00-18:00")
      item.available_dates["2020/03/30"].value.should eq("[08:00 , 18:00]")
      item.base_price.should eq(3.94)
      item.carrier_name.should eq("DPD")
      item.cash_on_delivery.apply_percentage_cash_on_delivery.should eq(0)
      item.cash_on_delivery.max_cash_on_delivery.should eq(0)
      item.cash_on_delivery.min_cash_on_delivery.should eq(0)
      item.cash_on_delivery.offered.should be_false
      item.cash_on_delivery.should be_a(Packlink::Service::CashOnDelivery)
      item.category.should eq("standard")
      item.country.should eq("DE")
      item.currency.should eq("EUR")
      item.customs_required.should be_false
      item.delivery_to_parcelshop.should be_false
      item.dropoff.should be_false
      item.first_estimated_delivery_date.should eq("2020/03/24")
      item.has_adult_signature.should be_false
      item.has_print_in_store.should be_false
      item.has_proof_of_delivery.should be_false
      item.id.should eq(20154)
      item.insurance.should be_a(Packlink::Service::Insurance)
      item.insurance.additional_insurance.should be_true
      item.insurance.apply_percentage_aditional_insurance.should eq(2.0)
      item.insurance.base_insurance.should eq(520.0)
      item.labels_required.should be_true
      item.logo_id.should eq("dpd")
      # item.max_dimensions_message.should be_nil => string or int?
      item.name.should eq("Classic Kleinpaket")
      item.price.should be_a(Packlink::Service::Price)
      item.price.base_price.should eq(BigDecimal.new("3.9399999999999999"))
      item.price.currency.should eq("EUR")
      item.price.tax_price.should eq(0.0)
      item.price.total_price.should eq(BigDecimal.new("3.9399999999999999"))
      item.service_info.first.icon.should eq("printer")
      item.service_info.first.text.should eq("service-card.service-info.printer")
      item.service_info.should be_a(Array(Packlink::Service::Info))
      item.time_left_first_available_date.should be_a(Packlink::Service::TimeLeftFirstAvailableDate)
      item.time_left_first_available_date.time_value.should eq(2)
      item.time_left_first_available_date.time_unit.should eq("DAYS")
      item.transit_hours.should eq("24")
      item.transit_time.should eq("1 DAYS")
      item.url_terms_and_conditions.should eq("https://www.dpd.com/de/home/siteutilities/agb")
    end
  end

  describe ".find" do
    it "fetches a given service" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services/available/20154/details")
        .to_return(body: read_fixture("services/get-response"))

      response = Packlink::Service.find({id: 20154})
      response.should be_a(Packlink::Service::FoundResponse)
    end
  end

  describe ".from" do
    it "returns a query builder" do
      Packlink::Service.from("GB", "BN2 1JJ").should be_a(Packlink::Service::Query)
    end

    it "accepts a client parameter" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=GB&from[zip]=BN2+1JJ&to[country]=BE&to[zip]=9000&packages[0][width]=15&packages[0][height]=15&packages[0][length]=15&packages[0][weight]=1.5")
        .with(headers: {"Authorization" => "from_key"})
        .to_return(body: read_fixture("services/all-response"))

      client = Packlink::Client.new("from_key")
      Packlink::Service
        .from("GB", "BN2 1JJ", client: client).to("BE", 9000)
        .package(15, 15, 15, 1.5).all
    end
  end

  describe ".to" do
    it "returns a query builder" do
      Packlink::Service.to("BE", "2000").should be_a(Packlink::Service::Query)
    end

    it "accepts a client parameter" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?to[country]=BE&to[zip]=9000&from[country]=GB&from[zip]=BN2+1JJ&packages[0][width]=20&packages[0][height]=20&packages[0][length]=20&packages[0][weight]=2")
        .with(headers: {"Authorization" => "to_key"})
        .to_return(body: read_fixture("services/all-response"))

      client = Packlink::Client.new("to_key")
      Packlink::Service
        .to("BE", 9000, client: client).from("GB", "BN2 1JJ")
        .package(20, 20, 20, 2).all
    end
  end

  describe ".package" do
    it "returns a query builder" do
      Packlink::Service.package(10, 10, 10, 1)
        .should be_a(Packlink::Service::Query)
    end

    it "accepts a client parameter" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?to[country]=BE&to[zip]=9000&from[country]=GB&from[zip]=BN2+1JJ&packages[0][width]=25&packages[0][height]=22&packages[0][length]=21&packages[0][weight]=20.1")
        .with(headers: {"Authorization" => "package_key"})
        .to_return(body: read_fixture("services/all-response"))

      client = Packlink::Client.new("package_key")
      Packlink::Service
        .package(25, 22, 21, 20.1, client: client)
        .to("BE", 9000).from("GB", "BN2 1JJ").all
    end
  end
end

describe Packlink::Service::Query do
  before_each do
    configure_test_api_key
  end

  describe "#initialize" do
    it "optionally accpets a client" do
      Packlink::Service::Query.new
      Packlink::Service::Query.new(Packlink::Client.new("init_key"))
    end
  end

  describe "#from" do
    it "adds a source" do
      query = Packlink::Service::Query.new
      query.from("GB", "BN2 1JJ").to("BE", 2000).package(10, 10, 10, 1)
      query.to_h["from"].should eq({"country" => "GB", "zip" => "BN2 1JJ"})
    end
  end

  describe "#to" do
    it "adds a destination" do
      query = Packlink::Service::Query.new
      query.from("GB", "BN2 1JJ").to("BE", 2000).package(10, 10, 10, 1)
      query.to_h["to"].should eq({"country" => "BE", "zip" => "2000"})
    end
  end

  describe "#package" do
    it "adds a package" do
      query = Packlink::Service::Query.new
      query.from("GB", "BN2 1JJ").to("BE", 2000)
      query.package(10, 10, 10, 1)
      query.package(5, 5, 5, 0.5)
      hash = query.to_h
      hash["packages"].size.should eq(2)
      hash["packages"]["0"].should eq({
        "width"  => "10",
        "height" => "10",
        "length" => "10",
        "weight" => "1",
      })
      hash["packages"]["1"].should eq({
        "width"  => "5",
        "height" => "5",
        "length" => "5",
        "weight" => "0.5",
      })
    end
  end

  describe "#all" do
    it "fetches the requested services" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=GB&from[zip]=BN2+1JJ&to[country]=BE&to[zip]=2000&packages[0][width]=30&packages[0][height]=20&packages[0][length]=10&packages[0][weight]=3&packages[1][width]=15&packages[1][height]=13&packages[1][length]=11&packages[1][weight]=1")
        .with(headers: {"Authorization" => "ki4SpxPdR8860exd2hZ23kUZ6MpJp07x"})
        .to_return(body: read_fixture("services/all-response"))

      services = Packlink::Service
        .from("GB", "BN2 1JJ").to("BE", 2000)
        .package(30, 20, 10, 3).package(15, 13, 11, 1).all
      services.should be_a(Packlink::List(Packlink::Service::Item))
    end

    it "optionally accepts a client to perform the call on" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/services?from[country]=GB&from[zip]=BN2+1JJ&to[country]=BE&to[zip]=2000&packages[0][width]=50&packages[0][height]=40&packages[0][length]=30&packages[0][weight]=9.5")
        .with(headers: {"Authorization" => "fabulous_key"})
        .to_return(body: read_fixture("services/all-response"))

      Packlink::Service
        .from("GB", "BN2 1JJ").to("BE", 2000)
        .package("50", "40", "30", "9.5")
        .all(client: Packlink::Client.new("fabulous_key"))
    end
  end

  describe "#to_h" do
    it "fails if from is missing" do
      expect_raises(Packlink::IncompleteQueryException) do
        Packlink::Service.to("DE", 12345).all
      end
    end

    it "fails if to is missing" do
      expect_raises(Packlink::IncompleteQueryException) do
        Packlink::Service.from("DE", 12345).all
      end
    end

    it "fails if no packages are given" do
      expect_raises(Packlink::IncompleteQueryException) do
        Packlink::Service.from("DE", 12345).to("DE", 12345).all
      end
    end
  end
end
