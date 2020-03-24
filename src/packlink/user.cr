struct Packlink
  struct User < Base
    will_create "users/api/keys", {
      token: String,
    }
    will_find "users/api/keys", {
      token: String,
    }

    def self.verify(key : String)
      find(headers: {"Authorization" => key}, client: client).token
    end

    def self.active?(key : String)
      !!verify(key)
    rescue e : Packlink::ResourceNotFoundException
      false
    end

    def self.activate(key : String)
      create(headers: {"Authorization" => key}, client: client).token
    end

    private def self.client
      Client.instance_without_api_key
    end
  end
end
