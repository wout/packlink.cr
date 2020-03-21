struct Packlink
  struct A
    alias HS2 = Hash(String, String)
    alias Scalar = String | Float64 | Int32 | Bool
    alias Zipcode = String | Int32
    alias Measurement = String | Float64 | Int32
    alias ParamsHash = Hash(String, Scalar)
    alias QueryHash = Hash(String, Hash(String, ParamsHash) | ParamsHash | Scalar)
  end
end
