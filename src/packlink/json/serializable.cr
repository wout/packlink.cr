struct Packlink
  struct Json
    module Serializable
      macro included
        include JSON::Serializable
      end

      macro json_field(name, type)
        {% camelized = name.id.stringify.camelcase(lower: true) %}
        @[JSON::Field(key: {{ camelized }})]
        getter {{ name.id }} : {{ type }}
      end
    end
  end
end
