struct Packlink
  abstract struct Base
    macro will_list(pattern, mapping = nil)
      def self.all(
        params : NamedTuple | Hash = A::HS2.new,
        query : NamedTuple | Hash = A::HS2.new,
        headers : NamedTuple | Hash = A::HS2.new,
        client : Client = Client.instance
      )
        path = AllPath.new(params).to_s
        json = client.get(path, query, headers: headers)
        List({% if mapping %}Item{% else %}String{% end %}).from_json(%({
          "items":#{json},
          "query":#{query.to_json},
          "params":#{params.to_json}
        }))
      end

      {% if mapping %}
        struct Item
          JSON.mapping({{ mapping }})
        end
      {% end %}

      struct AllPath < Packlink::Path
        getter pattern = {{ pattern }}
      end
    end

    macro will_find(pattern, mapping = nil)
      def self.find(
        params : NamedTuple | Hash = A::HS2.new,
        query : NamedTuple | Hash = A::HS2.new,
        headers : NamedTuple | Hash = A::HS2.new,
        client : Client = Client.instance
      )
        path = FindPath.new(params).to_s
        response = client.get(path, query, headers)
        {% if mapping %}
          FoundResponse.from_json(response)
        {% else %}
          true
        {% end %}
      end

      {% if mapping %}
        struct FoundResponse
          JSON.mapping({{ mapping }})
        end
      {% end %}

      struct FindPath < Packlink::Path
        getter pattern = {{ pattern }}
      end
    end

    macro will_create(pattern, mapping = nil)
      def self.create(
        body : NamedTuple | Hash = A::HS2.new,
        params : NamedTuple | Hash = A::HS2.new,
        query : NamedTuple | Hash = A::HS2.new,
        headers : NamedTuple | Hash = A::HS2.new,
        client : Client = Client.instance
      )
        path = CreatePath.new(params).to_s
        response = client.post(path, body, query, headers)
        {% if mapping %}
          CreatedResponse.from_json(response)
        {% else %}
          true
        {% end %}
      end

      {% if mapping %}
        struct CreatedResponse
          JSON.mapping({{ mapping }})
        end
      {% end %}

      struct CreatePath < Packlink::Path
        getter pattern = {{ pattern }}
      end
    end
  end
end
