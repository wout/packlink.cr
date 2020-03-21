struct Packlink
  struct A
    alias HS2 = Hash(String, String)
    alias Zipcode = String | Int32
    alias CommonValue = String | Float64 | Int32
    alias Measurement = CommonValue
    alias ParamsHash = Hash(String, CommonValue)
    alias QueryHash = Hash(String, Hash(String, ParamsHash) | ParamsHash | CommonValue)
  end
end
