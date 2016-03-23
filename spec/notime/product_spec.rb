require 'spec_helper'

shared_context 'basic_product_variables' do
  let(:product) { described_class.new }
  let(:reference) { "some_product_reference" }
  let(:name) { "T-Shirt" }
  let(:unit_type) { Notime::UnitTypes::STCK }
  let(:quantity) { 1 }
  let(:fee) { 42.23 }
  let(:image_url) { "http://example.com/image.jpg" }
  let(:type) { "100" }
  let(:labels) { ["Label1"] }

  let(:hash) {{
    reference: reference,
    name: name,
    unit_type: unit_type,
    quantity: quantity,
    fee: fee,
    image_url: image_url,
    type: type,
    labels: labels,
  }}
end

describe Notime::Product, '#initialize' do
  include_context('basic_product_variables')

  it 'sets an empty errors array' do
    expect(product.errors).to eq([])
  end

  it 'sets attributes from hash' do
    product = described_class.new hash

    expect(product.reference).to eq(reference)
    expect(product.name).to eq(name)
    expect(product.unit_type).to eq(unit_type)
    expect(product.quantity).to eq(quantity)
    expect(product.fee).to eq(fee)
    expect(product.image_url).to eq(image_url)
    expect(product.type).to eq(type)
    expect(product.labels).to eq(labels)
  end
end

describe Notime::Product, 'attributes' do
  include_context('basic_product_variables')

  it 'sets attributes by dot syntax' do
    product.reference = reference
    expect(product.reference).to eq(reference)

    product.name = name
    expect(product.name).to eq(name)

    product.unit_type = unit_type
    expect(product.unit_type).to eq(unit_type)

    product.quantity = quantity
    expect(product.quantity).to eq(quantity)

    product.fee = fee
    expect(product.fee).to eq(fee)

    product.image_url = image_url
    expect(product.image_url).to eq(image_url)

    product.type = type
    expect(product.type).to eq(type)

    product.labels = labels
    expect(product.labels).to eq(labels)
  end
end

describe Notime::Product, '#valid?' do
  include_context('basic_product_variables')

  it 'tests if name is valid' do
    product.valid?
    expect(product.errors).to include(":name is blank!")
    product.name = name
    product.valid?
    expect(product.errors).not_to include(":name is blank!")
  end

  it 'tests if unit_type is valid' do
    product.valid?
    expect(product.errors).to include(":unit_type is blank!")
    product.unit_type = unit_type
    product.valid?
    expect(product.errors).not_to include(":unit_type is blank!")
  end

  it 'tests if labels is valid' do
    product.valid?
    expect(product.errors).not_to include(":labels must be an Array!")
    product.labels = "foobar"
    product.valid?
    expect(product.errors).to include(":labels must be an Array!")
    product.labels = ["asdf"]
    product.valid?
    expect(product.errors).not_to include(":labels must be an Array!")
  end

  it 'skips all other validations when reference is set' do
    product.reference = reference
    expect(product.valid?).to be(true)
  end
end

describe Notime::Product, '#to_notime_hash' do
  include_context('basic_product_variables')

  it 'converts a poi to notime format' do
    poi = described_class.new(hash)
    expect(poi.to_notime_hash).to eq({"Reference"=>"some_product_reference",
      "Name"=>"T-Shirt",
      "UnitType"=>9,
      "Quantity"=>1,
      "Fee"=>42.23,
      "ImageUrl"=>"http://example.com/image.jpg",
      "Type"=>"100",
      "Labels"=>["Label1"]
    })
  end
end
