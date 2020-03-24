struct Packlink
  struct Tracking < Base
    will_find "shipments/:shipment_reference/track", {
      history: Array(Event),
    }

    def self.history(
      shipment_reference : String,
      client : Client = Client.instance
    )
      find({shipment_reference: shipment_reference}, client: client).history
    end

    struct Event
      JSON.mapping({
        city:        String,
        description: String,
        timestamp:   Int32,
      })

      def created_at
        Time.unix(@timestamp * 100)
      end
    end
  end
end
