struct Packlink
  struct Client
    API_VERSION = "v1"

    getter api_key : String?

    def initialize(@api_key : String? = Config.api_key)
      raise MissingApiKeyException.new("No API key provided") unless @api_key
    end

    def endpoint
      "https://api#{"sandbox" if Config.sandbox?}.packlink.com"
    end

    def perform_http_call
    end

    private def http_headers
      HTTP::Headers{
        "Accept"        => "application/json",
        "Content-Type"  => "application/json",
        "Authorization" => @api_key,
      }
    end

    private def http_client(uri : URI)
      client = HTTP::Client.new(uri)
      client.read_timeout = Config.read_timeout
      client.connect_timeout = Config.open_timeout
      client
    end
  end
end
