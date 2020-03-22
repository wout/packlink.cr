require "../spec_helper"

describe Packlink::Shipment do
  before_each do
    configure_test_api_key
  end

  describe ".find" do
    it "fetches a shipment by its reference" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/DE2015API0000003515")
        .to_return(body: read_fixture("shipments/get-response"))

      shipment = Packlink::Shipment.find({reference: "DE2015API0000003515"})
      shipment.base_price.should eq(15.85)
      shipment.canceled.should be_false
      shipment.carrier.should eq("Mondial Relay")
      shipment.collection.should be_a(Packlink::Shipment::Address)
      shipment.collection.city.should eq("Paris")
      shipment.collection.name.should eq("Daniel Werner")
      shipment.collection.country.should eq("Francia")
      shipment.collection.phone.should eq("01516113123")
      shipment.collection.street.should eq("Alleestr . 29")
      shipment.collection.postalcode.should eq("75001")
      shipment.collection.email.should eq("test@testing.com")
      shipment.collection_date.should eq("2015-04-16")
      shipment.collection_hour.should eq("00:00-24:00")
      shipment.content.should eq("Leggins, Schuhe")
      shipment.content_value.should eq(50.00)
      shipment.delivery.should be_a(Packlink::Shipment::Address)
      shipment.extras.should be_a(Array(String))
      shipment.insurance_coverage.should eq(50.00)
      shipment.insurance_price.should eq(1.49)
      shipment.order_date.should eq("2015-04-16")
      shipment.parcel_number.should eq("1")
      shipment.parcels.should be_a(Array(Packlink::Package))
      shipment.price.should eq(18.86)
      shipment.reference.should eq("DE2015API0000003515")
      shipment.service.should eq("Point Relais")
      shipment.shipment_custom_reference.should eq("eBay_11993382332")
      shipment.status.should eq("CARRIER_PENDING")
      shipment.total_taxes.should eq(3.01)
      shipment.tracking_codes.should be_a(Array(String))
      shipment.weight.should eq(1.00)
    end

    it "accepts a reference" do
      WebMock.stub(:get, "https://apisandbox.packlink.com/v1/shipments/DE2015API0000003515")
        .to_return(body: read_fixture("shipments/get-response"))

      shipment = Packlink::Shipment.find("DE2015API0000003515")
      shipment.reference.should eq("DE2015API0000003515")
    end
  end
end

describe Packlink::Shipment::Customs do
  describe ".build" do
    it "builds a customs object" do
      customs = test_shipment_customs
      customs.eori_number.should eq("GB123456789000")
      customs.sender_personalid.should eq("EX123456")
      customs.sender_type.should eq("private")
      customs.shipment_type.should eq("gift")
      customs.vat_number.should eq("GB123456789")
      item = customs.items.as(Array(Packlink::Shipment::Customs::Item)).first
      item.description_english.should eq("Hairdryer")
      item.quantity.should eq(2)
      item.weight.should eq(1.3)
      item.value.should eq(33.5)
      item.country_of_origin.should eq("GB")
    end
  end

  describe "#to_h" do
    test_shipment_customs.to_h.size.should eq(6)
  end
end

def test_shipment_customs
  Packlink::Shipment::Customs.build({
    eori_number:       "GB123456789000",
    sender_personalid: "EX123456",
    sender_type:       "private", # e.g. private, commercial_with_vat, commercial_without_vat
    shipment_type:     "gift",    # e.g. commercial_sale, document, gift, return, ... (in english)
    vat_number:        "GB123456789",
    items:             [{
      description_english: "Hairdryer",
      quantity:            2,
      weight:              1.3,
      value:               33.5,
      country_of_origin:   "GB",
    }],
  })
end
