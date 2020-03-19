struct Packlink
  struct Auth < Base
    will_find "login", {
      token: String,
    }

    def self.login(
      credentials : NamedTuple | Hash,
      client : Client = Client.instance
    )
      credentials = credentials.to_h.transform_keys(&.to_s)
      email = credentials.delete("email")
      password = credentials.delete("password")

      unless email && password
        raise AuthCredentialsMissingException.new(
          %(Both "email" and "password" are required))
      end

      find(credentials, headers: {
        "Authorization" => encoded_auth_header(email.to_s, password.to_s),
      }, client: client)
    end

    def self.encoded_auth_header(email : String, password : String)
      encoded = Base64.strict_encode([email, password].join(':'))
      "Basic #{encoded}"
    end
  end
end
