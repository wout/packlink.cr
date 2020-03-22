require "../spec_helper"

def test_customs
  Packlink::Customs.build({
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

describe Packlink::Customs do
  describe ".build" do
    it "builds a customs object" do
      customs = test_customs
      customs.eori_number.should eq("GB123456789000")
      customs.sender_personalid.should eq("EX123456")
      customs.sender_type.should eq("private")
      customs.shipment_type.should eq("gift")
      customs.vat_number.should eq("GB123456789")
      item = customs.items.as(Array(Packlink::Customs::Item)).first
      item.description_english.should eq("Hairdryer")
      item.quantity.should eq(2)
      item.weight.should eq(1.3)
      item.value.should eq(33.5)
      item.country_of_origin.should eq("GB")
    end
  end

  describe "#to_h" do
    test_customs.to_h.size.should eq(6)
  end
end
