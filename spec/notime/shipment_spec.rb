require 'spec_helper'

shared_context 'basic_shipment_variables' do
  let(:ship) { described_class.new }
  let(:guid) { "my_guid" }
  let(:reference) { "R123456789" }
  let(:pickup_date) { "2016-01-21" }
  let(:pickup_time_window_guid) { "pickup_guid_1" }
  let(:dropoff_time_window_guid) { "dropoff_guid_1" }
  let(:payment_info) { "additional payment information" }
  let(:payment_type) { Notime::PaymentTypes::CASH }
  let(:fee) { 42.23 }
  let(:note) { "some notes" }
  let(:shipment_type) { "100" } # not used so far
  let(:asap) { false } # not used so far

  let(:hash) {{
    reference: reference,
    pickup_date: pickup_date,
    pickup_time_window_guid: pickup_time_window_guid,
    dropoff_time_window_guid: dropoff_time_window_guid,
    payment_info: payment_info,
    payment_type: payment_type,
    fee: fee,
    note: note,
    shipment_type: shipment_type,
    asap: asap
  }}
end

describe Notime::Shipment, '#initialize' do
  include_context('basic_shipment_variables')

  it 'inits with empty arrays for error and products' do
    ship = described_class.new
    expect(ship.products).to eq([])
    expect(ship.errors).to eq([])
    expect(ship.pickup).to be_kind_of(Notime::Poi)
    expect(ship.dropoff).to be_kind_of(Notime::Poi)
  end

  it 'inits from a hash' do
    pickup_hash = {some: "pickup value"}
    dropoff_hash = {some: "dropoff value"}
    product_hash = {some: "product value"}
    allow(Notime::Poi).to receive(:new)

    expect(Notime::Poi).to receive(:new).with(pickup_hash).and_return("pickup")
    expect(Notime::Poi).to receive(:new).with(dropoff_hash).and_return("dropoff")
    expect(Notime::Product).to receive(:new).with(product_hash).and_return("product")

    hash[:pickup] = pickup_hash
    hash[:dropoff] = dropoff_hash
    hash[:products] = [product_hash]

    ship = described_class.new hash
    expect(ship.reference).to eq(reference)
    expect(ship.pickup_date).to eq(pickup_date)
    expect(ship.pickup_time_window_guid).to eq(pickup_time_window_guid)
    expect(ship.dropoff_time_window_guid).to eq(dropoff_time_window_guid)
    expect(ship.payment_info).to eq(payment_info)
    expect(ship.payment_type).to eq(payment_type)
    expect(ship.fee).to eq(fee)
    expect(ship.note).to eq(note)
    expect(ship.shipment_type).to eq(shipment_type)
    expect(ship.asap).to eq(asap)
    expect(ship.pickup).to eq("pickup")
    expect(ship.dropoff).to eq("dropoff")
    expect(ship.products).to eq(["product"])
  end
end

describe Notime::Shipment, '#from_guid' do
  include_context('basic_shipment_variables')

  it 'inits with a guid' do
    client_stub = double("client", shipment_status: {some: "value"})
    expect(Notime::Client).to receive(:new).and_return(client_stub)
    ship = described_class.from_guid(guid)
    expect(ship.guid).to eq(guid)
    expect(ship.status!).to eq({some: "value"})
  end
end


describe Notime::Shipment, '#attributes' do
  include_context('basic_shipment_variables')

  it 'sets attributes by dot syntax' do
    ship.reference = reference
    expect(ship.reference).to eq(reference)

    ship.guid = guid
    expect(ship.guid).to eq(guid)

    ship.pickup_date = pickup_date
    expect(ship.pickup_date).to eq(pickup_date)

    ship.pickup_time_window_guid = pickup_time_window_guid
    expect(ship.pickup_time_window_guid).to eq(pickup_time_window_guid)

    ship.dropoff_time_window_guid = dropoff_time_window_guid
    expect(ship.dropoff_time_window_guid).to eq(dropoff_time_window_guid)

    ship.payment_info = payment_info
    expect(ship.payment_info).to eq(payment_info)

    ship.payment_type = payment_type
    expect(ship.payment_type).to eq(payment_type)

    ship.fee = fee
    expect(ship.fee).to eq(fee)

    ship.note = note
    expect(ship.note).to eq(note)

    ship.shipment_type = shipment_type
    expect(ship.shipment_type).to eq(shipment_type)

    ship.asap = asap
    expect(ship.asap).to eq(asap)
  end

  it 'makes pickup and dropoff accessible' do
    ship.pickup.name = "John Doe"
    expect(ship.pickup.name).to eq("John Doe")
    ship.dropoff.name = "Jane Doe"
    expect(ship.dropoff.name).to eq("Jane Doe")
  end

  it 'cant set read only attributes' do
    expect { ship.pickup = "foo" }.to raise_error NoMethodError, /undefined method `pickup=' for/
    expect { ship.dropoff = "foo" }.to raise_error NoMethodError, /undefined method `dropoff=' for/
    expect { ship.products = "foo" }.to raise_error NoMethodError, /undefined method `products=' for/
    expect { ship.errors = "foo" }.to raise_error NoMethodError, /undefined method `errors=' for/
  end
end

describe Notime::Shipment, '#add_product' do
  include_context('basic_shipment_variables')

  it 'raises an error when no block is given' do
    expect { ship.add_product }.to raise_error RuntimeError, 'No block given'
  end

  it 'adds a product' do
    ship.add_product do |product|
      product.name = "testname"
    end
    expect(ship.products.first.name).to eq("testname")
  end
end

describe Notime::Shipment, '#to_notime_hash?' do
  include_context('basic_shipment_variables')

  before :each do
    Notime.configure do |config|
      config.key = "my_key"
      config.group_guid = "my_group_guid"
    end
  end

  it 'converts a shipment to notime format' do
    pickup_double = double("pickup", to_notime_hash: {some: "pickup values"})
    dropoff_double = double("dropoff", to_notime_hash: {some: "dropoff values"})
    product_double = double("product", to_notime_hash: {some: "product values"})

    allow(Notime::Poi).to receive(:new)
    expect(Notime::Poi).to receive(:new).with("pickup").and_return(pickup_double)
    expect(Notime::Poi).to receive(:new).with("dropoff").and_return(dropoff_double)
    expect(Notime::Product).to receive(:new).with("product").and_return(product_double)

    hash[:pickup] = "pickup"
    hash[:dropoff] = "dropoff"
    hash[:products] = ["product"]

    ship = described_class.new hash
    expect(ship.to_notime_hash).to eq({
      "Reference"=>"R123456789",
      "GroupGuid"=>"my_group_guid",
      "PickupDate"=>"2016-01-21",
      "PickupTimeWindowGuid"=>"pickup_guid_1",
      "DropoffTimeWindowGuid"=>"dropoff_guid_1",
      "PaymentInfo"=>"additional payment information",
      "PaymentType"=>1,
      "Fee"=>42.23,
      "Note"=>"some notes",
      "ShipmentType"=>"100",
      "ASAP"=>false,
      "Pickup" => {some: "pickup values"},
      "Dropoff" => {some: "dropoff values"},
      "Products" => [{some: "product values"}]
    })
  end
end

describe Notime::Shipment, '#valid?' do
  include_context('basic_shipment_variables')

  it 'validates pickup_date' do
    ship.valid?
    expect(ship.errors).to include(":pickup_date has a wrong format: ''")

    ship.pickup_date = "2016"
    ship.valid?
    expect(ship.errors).to include(":pickup_date has a wrong format: '2016'")

    ship.pickup_date = "2016-05"
    ship.valid?
    expect(ship.errors).to include(":pickup_date has a wrong format: '2016-05'")

    ship.pickup_date = "2016-05-"
    ship.valid?
    expect(ship.errors).to include(":pickup_date has a wrong format: '2016-05-'")

    ship.pickup_date = "foobar"
    ship.valid?
    expect(ship.errors).to include(":pickup_date has a wrong format: 'foobar'")

    ship.pickup_date = pickup_date
    ship.valid?
    expect(ship.errors).not_to include(":pickup_date is blank!")
  end

  it 'validates fee' do
    ship.valid?
    # fee is optional, only validate if set
    expect(ship.errors).not_to include(":fee has a wrong format")

    ship.fee = "foobar"
    ship.valid?
    expect(ship.errors).to include(":fee has a wrong format")

    ship.fee = "1.12"
    ship.valid?
    expect(ship.errors).not_to include(":fee has a wrong format")
  end

  it 'validates asap' do
    ship.valid?
    # asap is optional, only validate if set
    expect(ship.errors).not_to include(":asap must be a boolean")

    ship.asap = "foobar"
    ship.valid?
    expect(ship.errors).to include(":asap must be a boolean")

    ship.asap = true
    ship.valid?
    expect(ship.errors).not_to include(":asap must be a boolean")

    ship.asap = false
    ship.valid?
    expect(ship.errors).not_to include(":asap must be a boolean")
  end

  it 'calls pickup, dropoff and every product for #valid?' do
    product_double = double("product")
    ship.pickup_date = '2016-01-21'

    allow(ship).to receive(:products).and_return([product_double])

    expect(ship.pickup).to receive(:valid?).and_return(false)
    expect(ship.pickup).to receive(:errors).and_return(["error"])
    expect(ship.dropoff).to receive(:valid?).and_return(false)
    expect(ship.dropoff).to receive(:errors).and_return(["error"])
    expect(product_double).to receive(:valid?).and_return(false)
    expect(product_double).to receive(:errors).and_return(["error"])

    expect(ship.valid?).to eq(false)

    expect(ship.pickup).to receive(:valid?).and_return(true)
    expect(ship.pickup).to receive(:errors).and_return([])
    expect(ship.dropoff).to receive(:valid?).and_return(true)
    expect(ship.dropoff).to receive(:errors).and_return([])
    expect(product_double).to receive(:valid?).and_return(true)
    expect(product_double).to receive(:errors).and_return([])

    expect(ship.valid?).to eq(true)
  end
end

describe Notime::Shipment, '#book!' do
  include_context('basic_shipment_variables')

  # POI values
  let(:poi_reference) { "some_poi_reference" }
  let(:street_address) { "Fake Street 123" }
  let(:city) { "Fake City" }
  let(:post_code) { "0815" }
  let(:country_code) { "CH" }
  let(:poi_name) { "John Doe" }
  let(:phone) { "555-555-555" }
  let(:contact_name) { "Jane Doe" }
  let(:note) { "some notes" }
  let(:poi_labels) { ["POI Label 1", "POI Label 2"] }

  let(:poi_hash) {{
    reference: poi_reference,
    street_address: street_address,
    city: city,
    post_code: post_code,
    country_code: country_code,
    name: poi_name,
    phone: phone,
    contact_name: contact_name,
    note: note,
    labels: poi_labels,
  }}

  let(:product_reference) { "some_product_reference" }
  let(:product_name) { "T-Shirt" }
  let(:unit_type) { Notime::UnitTypes::STCK }
  let(:quantity) { 1 }
  let(:fee) { 42.23 }
  let(:image_url) { "http://example.com/image.jpg" }
  let(:type) { "100" }
  let(:product_labels) { ["Label1 Product"] }

  let(:product_hash) {{
    reference: product_reference,
    name: product_name,
    unit_type: unit_type,
    quantity: quantity,
    fee: fee,
    image_url: image_url,
    type: type,
    labels: product_labels,
  }}

  it 'books a shipment' do
    dummy_configuration

    client_stub = double("client")
    expect(Notime::Client).to receive(:new).and_return(client_stub)
    hash[:pickup] = poi_hash
    hash[:dropoff] = poi_hash
    hash[:products] = [product_hash]
    ship = described_class.new hash

    expect(client_stub).to receive(:shipment).with({
      "Reference"=>"R123456789",
      "GroupGuid"=>"some_group_guid",
      "PickupDate"=>"2016-01-21",
      "PickupTimeWindowGuid"=>"pickup_guid_1",
      "DropoffTimeWindowGuid"=>"dropoff_guid_1",
      "PaymentInfo"=>"additional payment information",
      "PaymentType"=>1,
      "Fee"=>42.23,
      "Note"=>"some notes",
      "ShipmentType"=>"100",
      "ASAP"=>false,
      "Pickup"=>{
        "Reference"=>"some_poi_reference",
        "StreetAddress"=>"Fake Street 123",
        "City"=>"Fake City",
        "PostCode"=>"0815",
        "CountryCode"=>"CH",
        "Name"=>"John Doe",
        "Phone"=>"555-555-555",
        "ContactName"=>"Jane Doe",
        "Note"=>"some notes",
        "Labels"=>["POI Label 1", "POI Label 2"]
      },
      "Dropoff"=>{
        "Reference"=>"some_poi_reference",
        "StreetAddress"=>"Fake Street 123",
        "City"=>"Fake City",
        "PostCode"=>"0815",
        "CountryCode"=>"CH",
        "Name"=>"John Doe",
        "Phone"=>"555-555-555",
        "ContactName"=>"Jane Doe",
        "Note"=>"some notes",
        "Labels"=>["POI Label 1", "POI Label 2"]
      },
      "Products"=>[{
        "Reference"=>"some_product_reference",
        "Name"=>"T-Shirt",
        "UnitType"=>9,
        "Quantity"=>1,
        "Fee"=>42.23,
        "ImageUrl"=>"http://example.com/image.jpg",
        "Type"=>"100",
        "Labels"=>["Label1 Product"]
      }]
    }).and_return({
      "ResultCode"=>0,
      "ResultText"=>"Success",
      "ShipmentGuid"=>"guid",
      "PickupReference"=>"pickup_ref1",
      "DropoffReference"=>"dropoff_ref1",
      "ErrorString"=>"some error"
    })

    result = ship.book!
    expect(result.success?).to be(true)
    expect(result).to be(ship.last_result)
    expect(ship.guid).to eq("guid")
  end

  it 'throws an error if the shipment is not valid' do
    expect { ship.book! }.to raise_error Notime::Shipment::InvalidError
  end
end

describe Notime::Shipment, '#status!' do
  include_context('basic_shipment_variables')

  it 'calls the status from notime API and sets it in the model' do
    client_stub = double("client", shipment_status: {some: "value"})
    expect(Notime::Client).to receive(:new).and_return(client_stub)
    ship = described_class.new
    ship.guid = guid
    expect(ship.status!).to eq({some: "value"})
  end
end

describe Notime::Shipment, '#cancel!' do
  include_context('basic_shipment_variables')

  it 'cancels a shipment and updates model values' do
    client_stub = double("client", shipment_cancel: {some: "value"})
    expect(Notime::Client).to receive(:new).and_return(client_stub)
    ship = described_class.new
    ship.guid = guid
    expect(ship.cancel!).to eq({some: "value"})
  end
end
