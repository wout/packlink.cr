# Packlink Pro API client for Crystal

Compare Courier Services or Send a Parcel with Packlink. This is the unofficial
[Crystal](https://crystal-lang.org/) shard for Packlink.

[![Build Status](https://travis-ci.org/tilishop/packlink.cr.svg?branch=master)](https://travis-ci.org/tilishop/packlink.cr)
[![GitHub version](https://badge.fury.io/gh/tilishop%2Fpacklink.cr.svg)](https://badge.fury.io/gh/tilishop%2Fpacklink.cr)

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
  config.environment = "sandbox" # or "production"
end
```

You can also include a client instance in each request you make:

```crystal
client = Packlink::Client.new("<your-api-key>")
shipments = Packlink::Shipment
  .from("GB", "BN2 1JJ")
  .to("BE", 2000)
  .package({width: 40, height: 30, length: 25, weight: 5})
  .all(client: client)
```

If you need to do multiple calls with the same API key, use the following helper:

```crystal
Packlink::Client.with_api_key("<your-api-key>") do |packlink|
  from_gb_to_be = packlink.shipment
    .from("GB", "BN2 1JJ").to("BE", 2000)
    .package({width: 40, height: 30, length: 25, weight: 5}).all
  from_de_to_fr = packlink.shipment
    .package({width: 40, height: 30, length: 25, weight: 5})
    .package({width: 10, height: 10, length: 10, weight: 1})
    .from("DE", 10587).to("FR", 75013).all
end
```

Available scoped calls for a given API key are:

```crystal
Packlink::Client.with_api_key("<your-api-key>") do |packlink|
  callback.register(*args)
  customs.pdf(*args)
  draft.create(*args)
  dropoff.all(*args)
  label.all(*args)
  order.create(*args)
  service.find(*args)
  service.from(*args)
  service.to(*args)
  service.package(*args)
  shipment.find(*args)
  tracking.history(*args)
end
```

### Registration and Authentication

User management is only required if you are creating accounts for other users.
For example, in a situation where other users can create an account for Packlink
through your platform or plugin.

#### Register a new user:

```crystal
temporary_token = Packlink::Register.user({
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

puts temporary_token # => e0f90eacfa678e20051c3a5bc2bcc05a...
```

#### Activation

Using the temporary token obtained at registration, check if the user is
activated.

```crystal
active = Packlink::User.active?("e0f90eac...")
```

If the user is not active, the permanent api token can be obtained as follows:

```crystal
unless Packlink::User.active?("e0f90eac...")
  permanent_token = Packlink::User.activate("e0f90eac...")
  puts permanent_token # => fa678e20...
end
```

#### Generating a new token

If a given user already has a Packlink Pro account, a new API key can be
generated:

```crystal
token = Packlink::Auth.generate({
  email:            "myaccount@packlink.com",
  password:         "myPassword",
  platform:         "pro",
  platform_country: "gb",
})
puts token # => fa678e20...
```

#### Password reset
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
services = Packlink::Service
  .from("GB", "BN2 1JJ")
  .to("BE", 9000)
  .package({width: 15, height: 15, length: 15, weight: 1.5})
  .all

service = services.first

service.id                                  # => 20154
service.carrier_name                        # => "DPD"
service.name                                # => "Classic Kleinpaket"
service.price.total_price                   # => 3.94
service.price.currency                      # => "EUR"
service.transit_hours                       # => "24"
service.available_dates["2020/03/30"].from  # => "08:00"
service.available_dates["2020/03/30"].till  # => "18:00"
service.available_dates["2020/03/30"].to_s  # => "08:00-18:00"
...
```

*__Note:__ For a full list if available fields, check the
[services spec fixture](https://github.com/tilishop/packlink.cr/blob/master/spec/fixtures/services/all-response.json).* 

You can also add multiple packages and the order of the method chain is not
important:

```crystal
services = Packlink::Service
  .package({width: 40, height: 30, length: 25, weight: 5})
  .from("GB", "BN2 1JJ")
  .package({width: 15, height: 15, length: 15, weight: 1.5})
  .to("BE", 9000)
  .package({width: 20, height: 15, length: 10, weight: 3})
  .all
```

With an instance of a `Packlink::Package` object:

```crystal
package = Packlink::Package.build({
  width: 40,
  height: 30,
  length: 25,
  weight: 5
})
services = Packlink::Service
  .package(package)
  .from("GB", "BN2 1JJ")
  .to("BE", 9000)
  .all
```

For more clarity, or a different order, use named arguments:

```crystal
services = Packlink::Service
  .package(package)
  .from(country: "GB", zip: "BN2 1JJ")
  .to(country: "BE", zip: 9000)
  .all
```

Finally, you can also avoid the method chain and use a named tuple or hash:

```crystal
services = Packlink::Service.all(query: {
  from:     {country: "DE", zip: 56457},
  to:       {country: "BE", zip: 9000},
  packages: {
    "0": {width: 10, height: 10, length: 10, weight: 1},
  },
})
```

Or even:

```crystal
services = Packlink::Service.all(query: {
  from:     {country: "DE", zip: 56457},
  to:       {country: "BE", zip: 9000},
  packages: {
    "0": Packlink::Package.build({width: 40, height: 30, length: 25, weight: 5}),
  },
})
```

### Get available services details

If you know the id of a service, its details can be fetched as follows:

```crystal
service = Packlink::Service.find(20154)
```

### Get Dropoffs

Gives you a list of the ten closest dropoff points.

```crystal
dropoffs = Packlink::Dropoff.all({
  service_id: 21369,
  country:    "GB",
  zip:        "BN2 1JJ",
})

dropoff = dropoffs.first

dropoff.address               # => "52 St. George's Road"
dropoff.city                  # => "Brighton"
dropoff.commerce_name         # => "St. Georges News"
dropoff.id                    # => "S16271"
dropoff.lat                   # => 50.817563999999997
dropoff.long                  # => -0.118057
dropoff.opening_times.monday  # => "06:00-21:00"
dropoff.phone                 # => "07461451073"
dropoff.zip                   # => "BN2 1EF"
```

### Create Order

Creates a new order. Each order can include several shipments.

An order consists of multiple parts, and that is how one should be built. It is
also possible to use one large `Hash` or `NamedTuple`. But using the method
below ensures type safety and completeness of the posted data.

```crystal
# 1. Build one or more packages
package = Packlink::Package.build({
  width: 15,
  height: 15,
  length: 10,
  weight: 1
})

# 2. Build a source address
from_address = Packlink::Address.build({
  city:     "Cannes",
  country:  "FR",
  email:    "test@packlink.com",
  name:     "TestName",
  phone:    "0666559988",
  state:    "FR",
  street1:  "Suffren 3",
  surname:  "TestLastName",
  zip_code: "06400",
})

# 3. Build a destination address
to_address = Packlink::Address.build({
  city:     "Paris",
  country:  "FR",
  email:    "test@packlink.com",
  name:     "TestName",
  phone:    "630465777",
  state:    "FR",
  street1:  "Avenue Marchal 1",
  surname:  "TestLastName",
  zip_code: "75001",
})

# 3b. Build a customs object (only required for shipments outside the EU)
customs = Packlink::Shipment::Customs.build({
  eori_number:       "GB123456789000",
  sender_personalid: "EX123456",
  sender_type:       "private",
  shipment_type:     "gift",
  vat_number:        "GB123456789",
  items:             [{
    description_english: "Hairdryer",
    quantity:            2,
    weight:              1.3,
    value:               33.5,
    country_of_origin:   "GB",
  }],
})

# 4. Build shipment (can be multiple within one order)
shipment = Packlink::Order::Shipment.build({
  from:                       from_address,
  to:                         to_address,
  packages:                   [package],
  customs:                    customs,
  content:                    "Test content",
  contentvalue:               160,
  dropoff_point_id:           "062049",
  service_id:                 20149,
  shipment_custom_reference:  "69a280b2-f7db-11e6-915e-5c54c4398ed2",
  source:                     "source_inbound",
})

# 5. Create order
order = Packlink::Order.create({
  order_custom_reference: "Beautiful leggins from eBay",
  shipments:              [shipment]
})

# If everything went well, you will receive an order summary:

order.order_reference             # => "DE00019732CF"
order.total_amount                # => 4.9

line = order.shipments.first      # => Packlink::Order::ShipmentLine

line.shipment_custom_reference    # => "eBay_11993382332"
line.shipment_reference           # => "DE000193392AB"
line.insurance_coverage_amount    # => 750.0
line.total_price                  # => 4.9
line.receipt                      # => "http://url/to/receipt"
```

### Create Draft

Creates a new draft shipment. Building a draft shipment is exactly the same as
building a shipment for an order, except that in a draft, all fields are
optional.

```crystal
draft = Packlink::Draft.create({
  from:                       from_address,
  to:                         to_address,
  packages:                   [package],
  content:                    "Test content",
  contentvalue:               160,
  dropoff_point_id:           "062049",
  service_id:                 20149,
  shipment_custom_reference:  "69a280b2-f7db-11e6-915e-5c54c4398ed2",
  source:                     "source_inbound",
})

draft.shipment_reference   # => "DE00019732CF"
```

### Get Labels

Returns the shipping labels in PDF format (A4) for the given shipment
reference:

```crystal
labels = Packlink::Label.all("ES00019388AB")

puts labels.first   # => "http://packlink.de/de/purchase/PostVenta/getLabelsByRef?ref=52cf..."
```

*__Note:__ In many cases, there will only be one shipping label.*

### Get Customs

Returns the shipping customs PDF url.

```crystal
pdf = Packlink::Customs.pdf("DE2015API0000003515")

puts pdf   # => "http://static.packitos.com/prodev-pro/customs/c24a19d1bf25df8..."
```

### Get Shipment Details

Returns the shipping details.

```crystal
shipment = Packlink::Shipment.find("DE2015API0000003515")

shipment.base_price         # => 15.85
shipment.carrier            # => "Mondial Relay"
shipment.collection.city    # => "Paris"
shipment.collection.name    # => "Daniel Werner"
shipment.collection_date    # => "2015-04-16"
shipment.collection_hour    # => "00:00-24:00"
...
```

*__Note:__ For a full list if available fields, check the
[shipment spec fixture](https://github.com/tilishop/packlink.cr/blob/master/spec/fixtures/shipments/get-response.json).*

### Track a Shipment

Returns the tracking history of your shipment.

```crystal
history = Packlink::Tracking.history("ES00019388AB")
event = history.first

event.city          # => "MIAMI"
event.created_at    # => 2020-02-18 04:03:20.0 UTC : Time
event.description   # => "DELIVERED"
event.timestamp     # => 14242322
```

### Registering and receiving Shipment Callbacks

Store a url to notifiy shipment events. This call should be done only once per
Packlink client since the configured url will be used to send status updates for
all shipments of the client.

```crystal
success = Packlink::Callback.register("https://www.urlexample.com/packlink")

puts success   # => true
```

#### Event Callbacks

On the configured endpoints, you could process the events as follows:

```crystal
# grab the posted JSON
json = post.body

# parse the event
event = Packlink::Callback::Event.from_json(json)

event.name                            # => "shipment.carrier.success"
event.created_at                      # => 2020-01-01 15:55:23.0 UTC : Time
event.data.shipment_custom_reference  # => "eBay_11993382332589"
event.data.shipment_reference         # => "DE567YH981230AA"
```

#### Available events
- `shipment.carrier.success`: Shipment registered successfully in carrier's system.
- `shipment.carrier.fail`: Shipment failed to register in carrier's system.
- `shipment.label.ready`: Labels ready to print.
- `shipment.label.fail`: Labels have failed.
- `shipment.tracking.update`: Shipment is in transit.
- `shipment.delivered`: Shipment has been delivered.

## Contributing

1. Fork it at https://github.com/tilishop/packlink.cr/fork
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer
- [tilishop](https://github.com/tilishop) - owner and maintainer