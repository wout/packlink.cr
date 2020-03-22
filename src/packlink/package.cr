struct Packlink
  struct Package
    include Mixins::Buildable

    buildable({
      width:  A::Measurement,
      height: A::Measurement,
      length: A::Measurement,
      weight: A::Measurement,
    })
  end
end
