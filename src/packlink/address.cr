struct Packlink
  struct Address
    getter :email, :phone, :name, :surname, :street, :zip, :city, :country, :state

    def initialize(
      @email : String,
      @phone : String,
      @name : String,
      @surname : String,
      @street : String,
      @zip : String,
      @city : String,
      @country : String,
      @state : String = ""
    )
      @state = @state.blank? ? @country : @state
    end

    def to_h
      {
        "email"    => @email,
        "phone"    => @phone,
        "name"     => @name,
        "surname"  => @surname,
        "street1"  => @street,
        "zip_code" => @zip,
        "city"     => @city,
        "country"  => @country,
        "state"    => @state,
      }
    end

    delegate :to_json, to: to_h
  end
end
