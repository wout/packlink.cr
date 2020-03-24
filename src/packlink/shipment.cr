struct Packlink
  struct Shipment < Base
    will_find "shipments/:reference", {
      base_price:                BigDecimal,
      canceled:                  Bool,
      carrier:                   String,
      collection:                Address,
      collection_date:           String,
      collection_hour:           String,
      content:                   String,
      content_value:             BigDecimal,
      delivery:                  Address,
      extras:                    Array(String),
      insurance_coverage:        BigDecimal,
      insurance_price:           BigDecimal,
      order_date:                {key: "orderDate", type: String},
      parcel_number:             String | Int32,
      parcels:                   Array(Package),
      price:                     BigDecimal,
      reference:                 String,
      service:                   String,
      shipment_custom_reference: String,
      status:                    String,
      total_taxes:               BigDecimal,
      tracking_codes:            Array(String),
      weight:                    BigDecimal,
    }

    def self.find(
      reference : String,
      client : Client = Client.instance
    )
      find({reference: reference}, client: client)
    end

    struct Address
      JSON.mapping({
        city:       String,
        name:       String,
        country:    String,
        phone:      String,
        street:     String,
        postalcode: String,
        email:      String,
      })
    end

    struct Customs
      include Mixins::Buildable

      buildable({
        sender_type:       String?,
        eori_number:       String?,
        vat_number:        String?,
        shipment_type:     String?,
        sender_personalid: String?,
        items:             Array(Item)?,
      })

      struct Item
        JSON.mapping({
          description_english: String?,
          quantity:            Int32?,
          weight:              Float64,
          value:               Float64,
          country_of_origin:   String?,
        })
      end
    end
  end
end
