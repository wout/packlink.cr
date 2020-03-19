struct Packlink
  struct ApiKey < Base
    will_create "users/api/keys", {
      token: String,
    }
    will_find "users/api/keys", {
      token: String,
    }

    def self.verify(key : String, client : Client = Client.instance)
      find(headers: {"Authorization" => key}, client: client)
    end

    def self.valid?(key : String, client : Client = Client.instance)
      verify(key, client).token == key
    end

    def self.renew(key : String, client : Client = Client.instance)
      create(headers: {"Authorization" => key}, client: client)
    end
  end
end
