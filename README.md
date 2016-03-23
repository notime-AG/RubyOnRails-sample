# Notime

Ruby wrapper for the Notime API https://developer.notimeapi.com/

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'notime'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install notime

## Configuration

First of all, you have to configure Notime with your `key` and your `group_id`

```ruby
Notime.configure do |cfg|
  cfg.key = "your_key"
  cfg.group_guid = "your_group_id"
end
```

## Book a shipment

You can either set shipment parameters by dot syntax or by hash

### By dot syntax

```ruby
# dot syntax
ship = Notime::Shipment.new
ship.pickup_date = "2016-01-22"
ship.pickup_time_window_guid = "guid123"
ship.dropoff_time_window_guid = "guid456"
ship.payment_info = "some info about your payment"
ship.payment_type = Notime::PaymentTypes::CASH
ship.fee = 42.23
ship.note = "a note for your shipment"
ship.asap = false # default false

ship.pickup.reference = "some_pickup_reference"
ship.pickup.street_address = "Badenerstrasse 97" # mandatory, unless reference is set
ship.pickup.city = "Zürich" # mandatory, unless reference is set
ship.pickup.post_code = "8004" # mandatory, unless reference is set
ship.pickup.country_code = "CH" # mandatory, unless reference is set
ship.pickup.name = "John Doe" # optional
ship.pickup.phone = "+41987654321" # optional
ship.pickup.contact_name = "A contact name" # optional
ship.pickup.note = "A note" # optional
ship.pickup.labels = ["Label 1", "Label 2"] # optional

ship.dropoff.reference = "some_dropoff_reference"
ship.dropoff.street_address = "Birmensdorferstrasse 97" # mandatory, unless reference is set
ship.dropoff.city = "Zürich" # mandatory, unless reference is set
ship.dropoff.post_code = "8004" # mandatory, unless reference is set
ship.dropoff.country_code = "CH" # mandatory, unless reference is set
ship.dropoff.name = "notime AG" # optional
ship.dropoff.phone = "+41-44 520 86 34" # optional
ship.dropoff.note = "A note" # optional
ship.dropoff.contact_name = "A contact name" # optional
ship.dropoff.labels = ["Label 1", "Label 2"] # optional

ship.add_product do |product| # optional
  product.reference = "some product_reference"
  product.name = "Test Product" # mandatory when no reference
  product.unit_type = Notime::UnitTypes::EURO_PALET_DESC
  product.quantity = 1
  product.fee = 14.0
  product.image_url = "http://test.com/image.png"
  product.labels = ["Label 1"]
end
response = ship.book!
##<Notime::BookResult:0x007fb852029858
 # @dropoff_reference="43c84c29-f071-416e-a0b7-38fe4b4e5cf8",
 # @error_string=nil,
 # @pickup_reference="48da67c3-ae30-4fcb-8206-b31632f7cadb",
 # @result_code=0,
 # @result_text="Success",
 # @shipment_guid="a15b230b-27e5-46df-b0d4-656ac62faf5c">
```

### By hash

```ruby
ship = Notime::Shipment.new({
  pickup_date: "2016-01-22",
  pickup_time_window_guid: "guid123",
  dropoff_time_window_guid: "guid456",
  payment_info: "info about your payment",
  payment_type: Notime::PaymentTypes::CASH,
  fee: 42.23,
  note: "a note for your shipment",
  asap: true,
  pickup: {
    reference: "some_pickup_reference",
    street_address: "Badenerstrasse 97",
    city: "Zürich",
    post_code: "8004",
    country_code: "CH",
    name: "John Doe",
    phone: "+41987654321",
    contact_name: "A contact name",
    note: "A note",
    labels: ["Label 1", "Label 2"]
  },
  dropoff: {
    reference: "some_dropoff_reference",
    street_address: "Birmensdorferstrasse 97",
    city: "Zürich",
    post_code: "8004",
    country_code: "CH",
    name: "notime AG",
    phone: "+41-44 520 86 34",
    contact_name: "A contact name",
    note: "A note",
    labels: ["Label 1", "Label 2"]
  },
  products: [{
    reference: "some_product_reference",
    name: "Test Product", # mandatory when no reference
    unit_type: Notime::UnitTypes::EURO_PALET_DESC,
    quantity: 1,
    fee: 14.0,
    image_url: "http://test.com/image.png",
    labels: ["Label 1"]
  }]
})
ship.book!
##<Notime::BookResult:0x007fb852029858
 # @dropoff_reference="43c84c29-f071-416e-a0b7-38fe4b4e5cf8",
 # @error_string=nil,
 # @pickup_reference="48da67c3-ae30-4fcb-8206-b31632f7cadb",
 # @result_code=0,
 # @result_text="Success",
 # @shipment_guid="a15b230b-27e5-46df-b0d4-656ac62faf5c">
```

## Status of a shipment

```ruby
ship = Notime::Shipment.from_guid('a15b230b-27e5-46df-b0d4-656ac62faf5c')
ship.status!
# => {"Status"=>10, "StatusString"=>"Nicht zugewiesen", "ErrorString"=>nil}
```

## Cancel a shipment

```ruby
ship = Notime::Shipment.from_guid('a15b230b-27e5-46df-b0d4-656ac62faf5c')
ship.cancel!
# => nil
# because cancel returns no body, the result is nil. If an error occurs, the notime API returns sth like this:
# => {"Message"=>"The request is invalid."}
```