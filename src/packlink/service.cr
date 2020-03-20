struct Packlink
  struct Service < Base
    will_list "services", {
      available_dates:                Hash(String, Hours),
      base_price:                     BigDecimal,
      carrier_name:                   String,
      cash_on_delivery:               CashOnDelivery,
      category:                       String,
      country:                        String,
      currency:                       String,
      customs_required:               Bool,
      delivery_to_parcelshop:         Bool,
      dropoff:                        Bool,
      first_estimated_delivery_date:  String,
      has_adult_signature:            Bool,
      has_print_in_store:             Bool,
      has_proof_of_delivery:          Bool,
      id:                             Int32,
      insurance:                      Insurance,
      labels_required:                Bool,
      logo_id:                        String,
      name:                           String,
      price:                          Price,
      service_info:                   Array(Info),
      time_left_first_available_date: TimeLeftFirstAvailableDate,
      transit_hours:                  String,
      transit_time:                   String,
      url_terms_and_conditions:       String?,
    }

    def self.from(
      country : String,
      zip : Zipcode
    )
      Query.new.from(country, zip)
    end

    def self.to(
      country : String,
      zip : Zipcode
    )
      Query.new.to(country, zip)
    end

    def self.package(
      width : Measurement,
      height : Measurement,
      length : Measurement,
      weight : Measurement
    )
      Query.new.package(width, height, length, weight)
    end

    class Query
      def initialize
        @query = Hash(String, HS2).new
        @packages = Array(HS2).new
      end

      def from(
        country : String,
        zip : Zipcode
      )
        @query["from"] = {
          "country" => country,
          "zip"     => zip,
        }.transform_values(&.to_s)
        self
      end

      def to(
        country : String,
        zip : Zipcode
      )
        @query["to"] = {
          "country" => country,
          "zip"     => zip,
        }.transform_values(&.to_s)
        self
      end

      def package(
        width : Measurement,
        height : Measurement,
        length : Measurement,
        weight : Measurement
      )
        @packages.push({
          "width"  => width,
          "height" => height,
          "length" => length,
          "weight" => weight,
        }.transform_values(&.to_s))
        self
      end

      def all(client : Client = Client.instance)
        Packlink::Service.all(query: to_h, client: client)
      end

      def to_h
        if @query["from"]? && @query["to"]? && @packages.any?
          keys = (0..(@packages.size - 1)).to_a.map(&.to_s)
          @query.merge({"packages" => Hash.zip(keys, @packages)})
        else
          raise IncompleteQueryException.new(
            %(The "from", "to" and "packages" parameters are required))
        end
      end
    end

    struct CashOnDelivery
      JSON.mapping({
        apply_percentage_cash_on_delivery: BigDecimal,
        offered:                           Bool,
        max_cash_on_delivery:              BigDecimal,
        min_cash_on_delivery:              BigDecimal,
      })
    end

    struct Insurance
      JSON.mapping({
        additional_insurance:                 Bool,
        apply_percentage_aditional_insurance: BigDecimal,
        base_insurance:                       BigDecimal,
        max_insurance:                        BigDecimal,
      })
    end

    struct Hours
      getter value : String
      getter open_at : String
      getter closed_at : String

      def initialize(pull : JSON::PullParser)
        @value = pull.read_string
        @open_at, @closed_at = @value.scan(/\d{2}\:\d{2}/).map(&.[0])
      end

      def to_s
        "#{@open_at}-#{@closed_at}"
      end
    end

    struct Info
      JSON.mapping({
        text: String,
        icon: String,
      })
    end

    struct Price
      JSON.mapping({
        base_price:  BigDecimal,
        currency:    String,
        tax_price:   BigDecimal,
        total_price: BigDecimal,
      })
    end

    struct TimeLeftFirstAvailableDate
      JSON.mapping({
        time_value: Int32,
        time_unit:  String,
      })
    end
  end
end
