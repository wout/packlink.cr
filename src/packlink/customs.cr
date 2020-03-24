struct Packlink
  struct Customs < Base
    will_find "shipments/:shipment_reference/customs", {
      url: String,
    }

    def self.pdf(
      shipment_reference : String,
      client : Client = Client.instance
    )
      find({shipment_reference: shipment_reference}, client: client).url
    end
  end
end
