struct Packlink
  class Exception < Exception; end

  class MissingApiKeyException < Packlink::Exception; end

  class InvalidEnvironmentException < Packlink::Exception; end

  class MethodNotSupportedException < Packlink::Exception; end
end
