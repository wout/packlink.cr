struct Packlink
  struct Address
    include Mixins::Buildable

    buildable({
      email:    String?,
      phone:    String,
      name:     String,
      surname:  String,
      street1:  String,
      zip_code: String,
      city:     String,
      country:  String,
      state:    String?,
    })
  end
end
