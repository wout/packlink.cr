struct Packlink
  struct List(T)
    include JSON::Serializable

    getter items : Array(T)
    getter query : A::QueryHash
    getter params : A::ParamsHash

    forward_missing_to @items
  end
end
