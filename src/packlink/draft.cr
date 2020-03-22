struct Packlink
  struct Draft < Base
    will_create "shipments", {
      shipment_reference: String,
    }
  end
end
