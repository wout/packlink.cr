# Packlink Pro API client for Crystal

Compare Courier Services or Send a Parcel with Packlink.

This is the unofficial [Crystal](https://crystal-lang.org/) shard for Packlink.

## Installation

Add packlink as a depencency to your application's `shard.yml`:

```yaml
dependencies:
  mollie:
    github: tilishop/packlink.cr
```

Then run `shards install`.

## Usage

### Configuring the API key

Create an initializer and add the following line:

```crystal
Packlink.configure do |config|
  config.api_key = "<your-api-key>"
end
```

You can also include a client instance in each request you make:

```crystal
shipments = Packlink::Shipment
  .from("GB", "BN2 1JJ")
  .to("BE", 2000)
  .package(40, 30, 20, 1.5)
  .all(client: Packlink::Client.new("<your-api-key>"))
```

If you need to do multiple calls with the same API Key, use the following helper:

```crystal
Packlink::Client.with_api_key("<your-api-key>") do |packlink|
  from_gb_to_be = packlink.shipment
    .from("GB", "BN2 1JJ").to("BE", 2000)
    .package(40, 30, 20, 1.5).all
  from_de_to_fr = packlink.shipment
    .from("DE", 10587).to("FR", 75013)
    .package(40, 30, 20, 3).package(10, 10, 10, 0.5).all
end
```

## Contributing

1. Fork it at https://github.com/tilishop/packlink.cr/fork
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer
- [tilishop](https://github.com/tilishop) - owner and maintainer