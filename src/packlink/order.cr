struct Packlink
  struct Order < Base
    will_create "orders", {
      order_reference: String,
      shipments:       Array(ShipmentLine),
      total_amount:    BigDecimal,
    }

    struct Shipment
      include Mixins::Buildable

      buildable({
        content:                   String,
        contentvalue:              Float64,
        dropoff_point_id:          String | Int32,
        service_id:                String | Int32,
        shipment_custom_reference: String,
        source:                    String,
        packages:                  Array(Package),
        from:                      Address,
        to:                        Address,
        additional_data:           Hash(String, A::Scalar),
      })
    end

    struct ShipmentLine
      JSON.mapping({
        shipment_custom_reference: String,
        shipment_reference:        String,
        insurance_coverage_amount: BigDecimal,
        total_price:               BigDecimal,
        receipt:                   String,
      })
    end
  end
end
