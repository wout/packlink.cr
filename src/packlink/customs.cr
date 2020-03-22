struct Packlink
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
