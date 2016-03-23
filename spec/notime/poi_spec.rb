require 'spec_helper'

shared_context 'basic_poi_variables' do
  let(:poi) { described_class.new }
  let(:reference) { "some_poi_reference" }
  let(:street_address) { "Fake Street 123" }
  let(:city) { "Fake City" }
  let(:post_code) { "0815" }
  let(:country_code) { "CH" }
  let(:name) { "John Doe" }
  let(:phone) { "555-555-555" }
  let(:contact_name) { "Jane Doe" }
  let(:note) { "some notes" }
  let(:labels) { ["Label 1", "Label 2"] }

  let(:hash) {{
    reference: reference,
    street_address: street_address,
    city: city,
    post_code: post_code,
    country_code: country_code,
    name: name,
    phone: phone,
    contact_name: contact_name,
    note: note,
    labels: labels,
  }}
end

describe Notime::Poi, '#initialize' do
  include_context('basic_poi_variables')

  it 'sets an empty errors array' do
    expect(poi.errors).to eq([])
  end

  it 'sets attributes from hash' do
    poi = described_class.new hash

    expect(poi.reference).to eq(reference)
    expect(poi.street_address).to eq(street_address)
    expect(poi.city).to eq(city)
    expect(poi.post_code).to eq(post_code)
    expect(poi.country_code).to eq(country_code)
    expect(poi.name).to eq(name)
    expect(poi.phone).to eq(phone)
    expect(poi.contact_name).to eq(contact_name)
    expect(poi.note).to eq(note)
    expect(poi.labels).to eq(labels)
  end
end

describe Notime::Poi, 'attributes' do
  include_context('basic_poi_variables')

  it 'sets attributes by dot syntax' do
    poi.reference = reference
    expect(poi.reference).to eq(reference)

    poi.street_address = street_address
    expect(poi.street_address).to eq(street_address)

    poi.city = city
    expect(poi.city).to eq(city)

    poi.post_code = post_code
    expect(poi.post_code).to eq(post_code)

    poi.country_code = country_code
    expect(poi.country_code).to eq(country_code)

    poi.name = name
    expect(poi.name).to eq(name)

    poi.phone = phone
    expect(poi.phone).to eq(phone)

    poi.contact_name = contact_name
    expect(poi.contact_name).to eq(contact_name)

    poi.note = note
    expect(poi.note).to eq(note)

    poi.labels = labels
    expect(poi.labels).to eq(labels)
  end
end

describe Notime::Poi, '#valid?' do
  include_context('basic_poi_variables')

  it 'tests if street_address is valid' do
    poi.valid?
    expect(poi.errors).to include(":street_address is blank!")
    poi.street_address = street_address
    poi.valid?
    expect(poi.errors).not_to include(":street_address is blank!")
  end

  it 'tests if city is valid' do
    poi.valid?
    expect(poi.errors).to include(":city is blank!")
    poi.city = city
    poi.valid?
    expect(poi.errors).not_to include(":city is blank!")
  end

  it 'tests if post_code is valid' do
    poi.valid?
    expect(poi.errors).to include(":post_code is blank!")
    poi.post_code = post_code
    poi.valid?
    expect(poi.errors).not_to include(":post_code is blank!")
  end

  it 'tests if country_code is valid' do
    poi.valid?
    expect(poi.errors).to include(":country_code is blank!")
    poi.country_code = country_code
    poi.valid?
    expect(poi.errors).not_to include(":country_code is blank!")
  end

  it 'tests if labels is valid' do
    poi.valid?
    expect(poi.errors).not_to include(":labels must be an Array!") # nil values are valid
    poi.labels = "foobar"
    poi.valid?
    expect(poi.errors).to include(":labels must be an Array!")
    poi.labels = ["asdf"]
    poi.valid?
    expect(poi.errors).not_to include(":labels must be an Array!")
  end

  it 'skips all other validations when reference is set' do
    poi.reference = reference
    expect(poi.valid?).to be(true)
  end
end

describe Notime::Poi, '#to_notime_hash' do
  include_context('basic_poi_variables')
  it 'converts a poi to notime format' do
    poi = described_class.new(hash)
    expect(poi.to_notime_hash).to eq({
      "Reference"=>"some_poi_reference",
      "StreetAddress"=>"Fake Street 123",
      "City"=>"Fake City",
      "PostCode"=>"0815",
      "CountryCode"=>"CH",
      "Name"=>"John Doe",
      "Phone"=>"555-555-555",
      "ContactName"=>"Jane Doe",
      "Note"=>"some notes",
      "Labels"=>["Label 1", "Label 2"]
    })
  end
end
