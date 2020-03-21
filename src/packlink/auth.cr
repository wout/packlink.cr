struct Packlink
  struct Auth < Base
    will_create "users/recover-password/notify", {} of String => String
    will_find "login", {
      token: String,
    }

    def self.login(
      credentials : NamedTuple | Hash,
      client : Client = Client.instance
    )
      credentials = Util.normalize_hash(credentials)
      email = credentials.delete("email")
      password = credentials.delete("password")

      unless email && password
        raise AuthCredentialsMissingException.new(
          %(Both "email" and "password" are required))
      end

      header = encoded_auth_header(email.to_s, password.to_s)
      response = find(
        query: credentials,
        headers: {"Authorization" => header},
        client: client)
      response.token
    end

    def self.reset_password(
      details : NamedTuple | Hash,
      client : Client = Client.instance
    )
      query = Util.normalize_hash(details)

      unless email = query.delete("email")
        raise AuthCredentialsMissingException.new("An email addess is required")
      end

      create({email: email}, query: query, client: client)
    end

    def self.encoded_auth_header(email : String, password : String)
      encoded = Base64.strict_encode([email, password].join(':'))
      "Basic #{encoded}"
    end
  end
end
