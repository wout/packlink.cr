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
    will_find "services/available/:id/details", {
      carrier_name:     String,
      service_name:     String,
      service_logo:     String,
      service_id:       String | Int32,
      enabled:          Bool,
      departure_type:   String,
      destination_type: String,
      service_details:  Array(String),
      packlink_info:    Array(String),
      service_type:     String,
    }

    def self.find(
      id : Int32 | String,
      client : Client = Client.instance
    )
      find({id: id}, client: client)
    end

    def self.from(
      country : String,
      zip : A::Zipcode,
      client : Client = Client.instance
    )
      Query.new(client).from(country, zip)
    end

    def self.to(
      country : String,
      zip : A::Zipcode,
      client : Client = Client.instance
    )
      Query.new(client).to(country, zip)
    end

    def self.package(
      package : Hash | NamedTuple,
      client : Client = Client.instance
    )
      package(Packlink::Package.build(package), client: client)
    end

    def self.package(
      package : Packlink::Package,
      client : Client = Client.instance
    )
      Query.new(client).package(package)
    end

    class Query
      def initialize(@client : Client = Client.instance)
        @query = Hash(String, A::HS2).new
        @packages = Array(A::HS2).new
      end

      def from(
        country : String,
        zip : A::Zipcode
      )
        @query["from"] = {
          "country" => country,
          "zip"     => zip,
        }.transform_values(&.to_s)
        self
      end

      def to(
        country : String,
        zip : A::Zipcode
      )
        @query["to"] = {
          "country" => country,
          "zip"     => zip,
        }.transform_values(&.to_s)
        self
      end

      def package(package : Packlink::Package)
        @packages.push(package.to_h.transform_values(&.to_s))
        self
      end

      def package(package : Hash | NamedTuple)
        package(Packlink::Package.build(package))
      end

      def all(client : Client? = nil)
        Packlink::Service.all(query: to_h, client: client || @client)
      end

      def to_h
        if @query["from"]? && @query["to"]? && !@packages.empty?
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
      getter from : String
      getter till : String

      def initialize(pull : JSON::PullParser)
        @value = pull.read_string
        @from, @till = @value.scan(/\d{2}\:\d{2}/).map(&.[0])
      end

      def to_s
        "#{@from}-#{@till}"
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
