struct Packlink
  struct Dropoff < Base
    will_list "dropoffs/:service_id/:country/:zip", {
      address:       String,
      city:          String,
      commerce_name: String,
      country:       String?,
      id:            String,
      lat:           BigDecimal,
      long:          BigDecimal,
      opening_times: {
        type: Packlink::Dropoff::OpeningTimes,
        root: "opening_times",
      },
      phone: String,
      state: String?,
      type:  String,
      zip:   String,
    }

    struct OpeningTimes
      JSON.mapping({
        sunday:    String,
        saturday:  String,
        tuesday:   String,
        wednesday: String,
        thursday:  String,
        friday:    String,
        monday:    String,
      })
    end
  end
end
