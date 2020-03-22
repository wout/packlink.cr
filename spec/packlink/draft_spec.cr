require "../spec_helper"

describe Packlink::Draft do
  before_each do
    configure_test_api_key
  end

  describe ".create" do
    it "creates a draft shipment" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/shipments")
        .to_return(body: read_fixture("drafts/post-response"))

      draft = Packlink::Draft.create({
        content:                   "Test content",
        contentvalue:              160,
        customs:                   test_draft_customs,
        dropoff_point_id:          "062049",
        service_id:                20149,
        shipment_custom_reference: "69a280b2-f7db-11e6-915e-5c54c4398ed2",
        source:                    "source_inbound",
        packages:                  [
          test_draft_package,
        ],
        from:            test_draft_address_from,
        to:              test_draft_address_to,
        additional_data: {
          postal_zone_id_from:   "",
          postal_zone_id_to:     "",
          shipping_service_name: "Test shipping service preference",
        },
      })

      draft.shipment_reference.should eq("DE00019732CF")
    end
  end
end

def test_draft_package
  Packlink::Package.build({
    width:  15,
    height: 15,
    length: 10,
    weight: 1,
  })
end

def test_draft_address_from
  Packlink::Address.build({
    city:     "Cannes",
    country:  "FR",
    email:    "test@packlink.com",
    name:     "TestName",
    phone:    "0666559988",
    state:    "FR",
    street1:  "Suffren 3",
    surname:  "TestLastName",
    zip_code: "06400",
  })
end

def test_draft_address_to
  Packlink::Address.build({
    city:     "Paris",
    country:  "FR",
    email:    "test@packlink.com",
    name:     "TestName",
    phone:    "630465777",
    state:    "FR",
    street1:  "Avenue Marchal 1",
    surname:  "TestLastName",
    zip_code: "75001",
  })
end

def test_draft_customs
  Packlink::Shipment::Customs.build({
    eori_number:       "GB123456789000",
    sender_personalid: "EX123456",
    sender_type:       "private",
    shipment_type:     "gift",
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
