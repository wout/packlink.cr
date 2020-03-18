struct Packlink
  struct Client
    API_VERSION = "v1"
    METHODS     = %w[GET POST DELETE]

    getter api_key : String?

    def initialize(@api_key : String? = Config.api_key)
      raise MissingApiKeyException.new("No API key provided") unless @api_key
    end

    def endpoint
      "https://api#{"sandbox" if Config.sandbox?}.packlink.com"
    end

    def perform_http_call(
      method : String,
      path : String,
      body : Hash | NamedTuple = HS2.new,
      query : Hash | NamedTuple = HS2.new
    )
      unless METHODS.includes?(method)
        raise MethodNotSupportedException.new(
          "Invalid HTTP Method #{method}")
      end

      client = http_client(URI.parse(endpoint))
      path = api_path(path)

      begin
        if method == "GET"
          response = client.get(path, headers: headers)
        else
          body = body.to_h.delete_if { |_k, v| v.nil? }.to_json
          response = client.exec(method, path, headers: headers, body: body)
        end
        render(response)
      rescue e : IO::Timeout
        raise RequestTimeoutException.new(e.message)
      rescue e : IO::EOFError | Errno
        raise Exception.new(e.message)
      end
    end

    def api_path(method : String, id : String? = nil)
      if method.starts_with?(endpoint)
        URI.parse(method).path
      else
        "/#{API_VERSION}/#{method}/#{id}".chomp("/")
      end
    end

    private def headers
      HTTP::Headers{
        "Accept"        => "application/json",
        "Content-Type"  => "application/json",
        "Authorization" => @api_key.as(String),
      }
    end

    private def http_client(uri : URI)
      client = HTTP::Client.new(uri)
      client.read_timeout = Config.read_timeout
      client.connect_timeout = Config.open_timeout
      client
    end

    private def render(response : HTTP::Client::Response)
      case response.status_code
      when 200, 201
        response.body
      when 204
        ""
      when 404
        body = %({"message":"Resource missing"})
        raise ResourceNotFoundException.from_json(body)
      else
        body = response.body.blank? ? %({"message":"Somehting went wrong"}) : response.body
        raise RequestException.from_json(body)
      end
    end

    def self.instance
      self.with_api_key(Config.api_key)
    end

    def self.with_api_key(api_key : String?)
      new(api_key)
    end

    def self.with_api_key(api_key : String?)
      yield(Packlink::Proxy.new(with_api_key(api_key)))
    end
  end
end
