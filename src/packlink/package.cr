struct Packlink
  struct Package
    getter :width, :height, :length, :weight

    def initialize(
      @width : A::Measurement,
      @height : A::Measurement,
      @length : A::Measurement,
      @weight : A::Measurement
    )
    end

    def to_h
      {
        "width"  => @width,
        "height" => @height,
        "length" => @length,
        "weight" => @weight,
      }
    end

    delegate :to_json, to: to_h
  end
end
