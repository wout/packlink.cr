struct Packlink
  struct Label < Base
    will_list "shipments/:shipment_reference/labels"

    def self.all(shipment_reference : String)
      all({shipment_reference: shipment_reference})
    end
  end
end
