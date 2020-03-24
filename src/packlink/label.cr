struct Packlink
  struct Label < Base
    will_list "shipments/:shipment_reference/labels"

    def self.all(
      shipment_reference : String,
      client : Client = Client.instance
    )
      all({shipment_reference: shipment_reference}, client: client)
    end
  end
end
