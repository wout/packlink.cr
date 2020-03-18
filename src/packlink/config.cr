struct Packlink
  module Config
    class_property api_key : String?
    class_property open_timeout : Int32 | Float64 = 60
    class_property read_timeout : Int32 | Float64 = 60
    class_getter environment : String = "sandbox"

    def self.environment=(env : String)
      if %w[sandbox production].includes?(env)
        @@environment = env
      else
        raise InvalidEnvironmentException.new(%(Unknown environment "#{env}"))
      end
    end
  end
end
