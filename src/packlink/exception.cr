struct Packlink
  class Exception < Exception; end

  class RequestException < Packlink::Exception
    JSON.mapping({
      message:  String?,
      messages: Array(Packlink::ExceptionMessage)?,
    })
  end

  class ExceptionMessage < Packlink::Exception
    JSON.mapping({
      message: String?,
    })
  end

  class MissingApiKeyException < Packlink::Exception; end

  class ParamsMissingException < Packlink::Exception; end

  class RequestTimeoutException < Packlink::Exception; end

  class InvalidEnvironmentException < Packlink::Exception; end

  class MethodNotSupportedException < Packlink::Exception; end

  class ResourceNotFoundException < Packlink::RequestException; end
end
