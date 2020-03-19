struct Packlink
  struct List(T)
    include JSON::Serializable

    getter items : Array(T)

    forward_missing_to @items
  end
end
