struct Packlink
  struct Customs < Base
    will_find "shipments/:shipment_reference/customs", {
      url: String,
    }

    def self.pdf(shipment_reference : String)
      find({shipment_reference: shipment_reference}).url
    end
  end
end
