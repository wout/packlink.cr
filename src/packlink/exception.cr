struct Packlink
  class Exception < Exception; end

  class RequestException < Packlink::Exception
    JSON.mapping({
      exception_message: {
        type: String?,
        key:  "message",
      },
      exception_messages: {
        type: Array(Packlink::ExceptionMessage)?,
        key:  "messages",
      },
    })

    def message
      if exception_message
        exception_message.to_s
      else
        exception_messages.as(Array(Packlink::ExceptionMessage))
          .map { |message| message.message.to_s }
          .join(", ")
          .downcase
          .capitalize
      end
    end
  end

  class ExceptionMessage < Packlink::Exception
    JSON.mapping({
      message: String?,
    })
  end

  class MissingApiKeyException < Packlink::Exception; end

  class ParamsMissingException < Packlink::Exception; end

  class RequestTimeoutException < Packlink::Exception; end

  class IncompleteQueryException < Packlink::Exception; end

  class InvalidEnvironmentException < Packlink::Exception; end

  class MethodNotSupportedException < Packlink::Exception; end

  class AuthCredentialsMissingException < Packlink::Exception; end

  class ResourceNotFoundException < Packlink::RequestException; end
end
