require "../spec_helper"

describe Packlink::Order do
  before_each do
    configure_test_api_key
  end

  describe ".create" do
    it "creates an order" do
      WebMock.stub(:post, "https://apisandbox.packlink.com/v1/orders")
        .to_return(status: 200, body: read_fixture("orders/post-response"))

      order = Packlink::Order.create({
        order_custom_reference: "Beautiful leggins from eBay",
        shipments:              [
          test_order_shipment,
        ],
      })
      order.order_reference.should eq("DE00019732CF")
      order.shipments.should be_a(Array(Packlink::Order::ShipmentLine))
      line = order.shipments.first
      line.shipment_custom_reference.should eq("eBay_11993382332")
      line.shipment_reference.should eq("DE000193392AB")
      line.insurance_coverage_amount.should eq(750.0)
      line.total_price.should eq(4.9)
      line.receipt.should eq("http://url/to/receipt")
      order.total_amount.should eq(4.9)
    end
  end
end

def test_order_shipment
  Packlink::Order::Shipment.build({
    content:                   "Test content",
    contentvalue:              160,
    dropoff_point_id:          "062049",
    service_id:                20149,
    shipment_custom_reference: "69a280b2-f7db-11e6-915e-5c54c4398ed2",
    source:                    "source_inbound",
    packages:                  [
      test_order_package,
    ],
    from:            test_order_address_from,
    to:              test_order_address_to,
    additional_data: {
      postal_zone_id_from:   "",
      postal_zone_id_to:     "",
      shipping_service_name: "Test shipping service preference",
    },
  })
end

def test_order_package
  Packlink::Package.build({
    width:  15,
    height: 15,
    length: 10,
    weight: 1,
  })
end

def test_order_address_from
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

def test_order_address_to
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
