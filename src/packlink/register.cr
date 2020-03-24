struct Packlink
  struct Register < Base
    will_create "register", {
      token: String,
    }

    def self.user(body : NamedTuple | Hash = A::HS2.new)
      create(body, client: Client.instance_without_api_key).token
    end
  end
end
