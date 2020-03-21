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
  email:                     "myaccount@packlink.com",
  estimated_delivery_volume: "1 - 10",
  ip:                        "123.123.123.123",
  password:                  "myPassword",
  phone:                     "+447987654321",
  platform:                  "PRO",
  platform_country:          "GB",
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

*__Note__: User registration is only required if you are creating accounts for
other users. For example, in a situation where other users can create an account
for Packlink through your platform or plugin.* 

### Activation

Using the temporary token obtained at registration, check if the user is
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

### Logging in

If a given user already has a Packlink Pro account, the API key can be retreived
by logging in:

```crystal
response = Packlink::Auth.login({
  email:            "myaccount@packlink.com",
  password:         "myPassword",
  platform:         "pro",
  platform_country: "gb",
})
token = response.token # => fa678e20...
```

### Password reset
If a given user has an account but forgot their password, a password reset link
can be requested:

```crystal
Packlink::Auth.reset_password({
  email:            "myaccount@packlink.com",
  platform:         "pro",
  platform_country: "gb",
})
```

*__Note:__ This will never fail and there is no response. If the email address
exists, an email will arrive. If not, nothing will happen.*

### Get Services

You need a source (`from`), destination (`to`) and at least one `package`:

```crystal
response = Packlink::Service
  .from("GB", "BN2 1JJ")
  .to("BE", 9000)
  .package(15, 15, 15, 1.5)
  .all

service = response.items.first

service.id                                  # => 20154
service.carrier_name                        # => "DPD"
service.name                                # => "Classic Kleinpaket"
service.price.total_price                   # => 3.94
service.price.currency                      # => "EUR"
service.transit_hours                       # => "24"
service.available_dates["2020/03/30"].from  # => "08:00"
service.available_dates["2020/03/30"].till  # => "18:00"
...
```

*__Note:__ For a full list if available field, check the
[services spec fixture](https://github.com/tilishop/packlink.cr/blob/master/spec/fixtures/services/all-response.json).* 

Order of the method chain is not important:

```crystal
response = Packlink::Service
  .package(15, 15, 15, 1.5)
  .from("GB", "BN2 1JJ")
  .to("BE", 9000)
  .all
```

You can also add multiple packages (there should be at lease one, though):

```crystal
response = Packlink::Service
  .package(40, 30, 25, 5)
  .package(15, 15, 15, 1.5)
  .package(20, 15, 10, 3)
  .from("GB", "BN2 1JJ")
  .to("BE", 9000)
  .all
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