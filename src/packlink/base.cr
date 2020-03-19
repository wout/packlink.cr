struct Packlink
  abstract struct Base
    macro will_create(pattern, mapping)
      def self.create(
        body : NamedTuple | Hash,
        params : NamedTuple | Hash = HS2.new,
        client : Client = Client.instance
      )
        path = CreatePath.new(params).to_s
        Response.from_json(client.post(path, body))
      end

      struct Response
        JSON.mapping({{ mapping }})
      end

      struct CreatePath < Packlink::Path
        getter pattern = {{ pattern }}
      end
    end

    macro will_find(pattern, mapping)
      def self.find(
        params : NamedTuple | Hash = HS2.new,
        client : Client = Client.instance
      )
        path = FindPath.new(params).to_s
        Resource.from_json(client.get(path))
      end

      struct Resource
        JSON.mapping({{ mapping }})
      end

      struct FindPath < Packlink::Path
        getter pattern = {{ pattern }}
      end
    end

    macro will_list(pattern, mapping)
      def self.all(
        params : NamedTuple | Hash = HS2.new,
        client : Client = Client.instance
      )
        path = AllPath.new(params).to_s
        json = client.get(path)
        List(Item).from_json(%({"items":#{json}}))
      end

      struct Item
        JSON.mapping({{ mapping }})
      end

      struct AllPath < Packlink::Path
        getter pattern = {{ pattern }}
      end
    end
  end
end
