struct Packlink
  struct Client
    API_ENDPOINT         = "https://api.packlink.com"
    API_SANDBOX_ENDPOINT = "https://apisandbox.packlink.com"
    API_VERSION          = "v1"

    METHODS = %w[GET POST DELETE]
  end
end
