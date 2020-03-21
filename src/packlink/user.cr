struct Packlink
  struct User < Base
    will_create "users/api/keys", {
      token: String,
    }
    will_find "users/api/keys", {
      token: String,
    }

    def self.verify(key : String, client : Client = Client.instance)
      find(headers: {"Authorization" => key}, client: client).token
    end

    def self.active?(key : String, client : Client = Client.instance)
      !!verify(key, client)
    rescue e : Packlink::ResourceNotFoundException
      false
    end

    def self.activate(key : String, client : Client = Client.instance)
      create(headers: {"Authorization" => key}, client: client).token
    end
  end
end
