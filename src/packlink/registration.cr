struct Packlink
  struct Registration < Base
    will_create "register", {
      token: String,
    }
  end
end
