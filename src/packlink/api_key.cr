struct Packlink
  struct ApiKey < Base
    will_create "users/api/keys", {
      token: String,
    }

    def self.renew(
      credentials : NamedTuple | Hash,
      client : Client = Client.instance
    )
      unless old_key = Util.normalize_hash(credentials).delete("old_key")
        raise MissingApiKeyException.new(
          %(Expected "old_key" parameter but none was given))
      end

      create(headers: {"Authorization" => old_key})
    end
  end
end
