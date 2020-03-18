struct Packlink
  struct Proxy
    getter client : Client

    def initialize(@client : Client)
    end

    {% begin %}
      {% resources = %w[
           order
         ] %}

      {% for resource in resources %}
        {% resource_class = resource.camelcase %}

        struct {{ resource_class.id }}
          getter client : Client

          def initialize(@client : Client)
          end

          {% for method in %w[all get create delete] %}
            def {{ method.id }}(*args)
              Packlink::{{ resource_class.id }}.{{ method.id }}(*args, client: @client)
            end
          {% end %}
        end

        def {{ resource.id }}
          Packlink::Proxy::{{ resource_class.id }}.new(@client)
        end
      {% end %}
    {% end %}
  end
end
