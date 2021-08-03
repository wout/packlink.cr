struct Packlink
  struct Client
    API_VERSION = "v1"
    METHODS     = %w[GET POST]

    getter api_key : String?

    def initialize(@api_key : String? = Config.api_key)
      raise MissingApiKeyException.new("No API key provided") unless @api_key
    end

    def initialize(require_key : Bool)
      if require_key
        initialize
      else
        @api_key = ""
      end
    end

    def endpoint
      "https://api#{"sandbox" if Config.sandbox?}.packlink.com"
    end

    def get(
      path : String,
      query : Hash | NamedTuple = A::HS2.new,
      headers : Hash | NamedTuple = A::HS2.new
    )
      perform_http_call("GET", path, query: query, headers: headers)
    end

    def post(
      path : String,
      body : Hash | NamedTuple,
      query : Hash | NamedTuple = A::HS2.new,
      headers : Hash | NamedTuple = A::HS2.new
    )
      perform_http_call("POST", path, body: body, query: query, headers: headers)
    end

    def perform_http_call(
      method : String,
      path : String,
      body : Hash | NamedTuple = A::HS2.new,
      query : Hash | NamedTuple = A::HS2.new,
      headers : Hash | NamedTuple = A::HS2.new
    )
      unless METHODS.includes?(method)
        raise MethodNotSupportedException.new(
          "Invalid HTTP Method #{method}")
      end

      client = http_client(URI.parse(endpoint))
      path = api_path(path)

      unless query.empty?
        nested_query = Util.build_nested_query(query)
        path += "?#{nested_query}"
      end

      request_headers = http_headers
      headers.each { |key, value| request_headers[key.to_s] = value }
      request_headers.delete("Authorization") if request_headers["Authorization"] == ""

      begin
        if method == "GET"
          response = client.get(path, headers: request_headers)
        else
          body = body.to_h.reject! { |_k, v| v.nil? }.to_json
          response = client.exec(method, path, headers: request_headers, body: body)
        end
        render(response)
      rescue e : IO::TimeoutError
        raise RequestTimeoutException.new(e.message)
      rescue e : IO::EOFError
        raise Exception.new(e.message)
      end
    end

    def api_path(path : String, id : String? = nil)
      if path.starts_with?(endpoint)
        URI.parse(path).path
      else
        "/#{API_VERSION}/#{path}".chomp("/")
      end
    end

    private def http_headers
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
        response.body.empty? ? "{}" : response.body
      when 204
        ""
      when 404
        body = %({"message":"Resource missing"})
        raise ResourceNotFoundException.from_json(body)
      else
        body = response.body.blank? ? %({"message":"Something went wrong"}) : response.body
        raise RequestException.from_json(body)
      end
    end

    def self.instance
      self.with_api_key(Config.api_key)
    end

    def self.instance_without_api_key
      new(false)
    end

    def self.with_api_key(api_key : String?)
      new(api_key)
    end

    def self.with_api_key(api_key : String?)
      yield(Packlink::Proxy.new(with_api_key(api_key)))
    end
  end
end
