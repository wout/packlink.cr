# Packlink Pro API client for Crystal

Compare Courier Services or Send a Parcel with Packlink. This is the unofficial
[Crystal](https://crystal-lang.org/) shard for Packlink.

## Installation

Add packlink as a depencency to your application's `shard.yml`:

```yaml
dependencies:
  packlink:
    github: tilishop/packlink.cr
```

Then run `shards install`.

## Usage

### Configuring the API key

To configure it globally, create an initializer and add the following line:

```crystal
Packlink.configure do |config|
  config.api_key = "<your-api-key>"
end
```

You can also include a client instance in each request you make:

```crystal
client = Packlink::Client.new("<your-api-key>")
shipments = Packlink::Shipment
  .from("GB", "BN2 1JJ")
  .to("BE", 2000)
  .package(40, 30, 20, 1.5)
  .all(client: client)
```

If you need to do multiple calls with the same API Key, use the following helper:

```crystal
Packlink::Client.with_api_key("<your-api-key>") do |packlink|
  from_gb_to_be = packlink.shipment
    .from("GB", "BN2 1JJ").to("BE", 2000)
    .package(40, 30, 20, 1.5).all
  from_de_to_fr = packlink.shipment
    .package(40, 30, 20, 3)
    .package(10, 10, 10, 0.5)
    .from("DE", 10587).to("FR", 75013).all
end
```

### Registration

Register a new user:

```crystal
response = Packlink::Registration.create({
  email:                     "myaccount@packlink.es",
  estimated_delivery_volume: "1 - 10",
  ip:                        "123.123.123.123",
  password:                  "myPassword",
  phone:                     "+447665588771",
  platform:                  "PRO",
  platform_country:          "ES",
  policies:                  {
    terms_and_conditions: true,
    data_processing:      true,
    marketing_emails:     true,
    marketing_calls:      true,
  },
  referral: {
    onboarding_product:     "dummy",
    onboarding_sub_product: "sub_dummy",
  },
  source: "https://urlwhereregistrationoffered",
})

# get the temporary token
token = response.token # => e0f90eacfa678e20051c3a5bc2bcc05a...
```

### Activation

Using the temporary token, obtained at registration, check if the user is
activated.

```crystal
active = Packlink::User.active?("e0f90eac...")
```

If the user is not active, the permanent api token can be obtained as follows:

```crystal
unless Packlink::User.active?("e0f90eac...")
  response = Packlink::User.activate("e0f90eac...")
  permanent_token = response.token # => fa678e20...
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