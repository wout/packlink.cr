struct Packlink
  struct Register < Base
    will_create "register", {
      token: String,
    }

    def self.user(
      body : NamedTuple | Hash = HS2.new,
      client : Client = Client.instance
    )
      create(body, client: client).token
    end
  end
end
