struct Packlink
  struct Mixins
    module Buildable
      macro buildable(mapping)
        JSON.mapping({{ mapping }})

        def self.build(data : NamedTuple | Hash)
          from_json(data.to_json)
        end

        def to_h
          {
            {% for key, value in mapping %}
              {% name = value.is_a?(NamedTuple) ? value[:key] : key %}
              "{{ name }}" => @{{ key.id }},
            {% end %}
          }
        end
      end
    end
  end
end
