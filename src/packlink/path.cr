struct Packlink
  abstract struct Path
    getter params : HS2

    abstract def pattern

    def initialize(params : NamedTuple | Hash = HS2.new)
      @params = Util.normalize_hash(params)
    end

    def to_s
      (path = pattern).scan(/:([a-z_]+)/).each do |match|
        if value = @params[match[1]]?
          path = path.gsub(match[0], value)
        else
          raise ParamsMissingException.new(%(Missing param "#{match[1]}"))
        end
      end
      path
    end
  end
end
