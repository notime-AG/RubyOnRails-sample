require 'spec_helper'

describe Notime::Client, '#initialize' do
  it 'raises an error when no key is set' do
    expect { Notime::Client.new }.to raise_error Notime::Errors::NoKeySet
  end

  it 'uses a key from Notime.configure' do
    Notime.configure do |config|
      config.key = "some_key"
      config.group_guid = "some_guid"
    end
    client = Notime::Client.new
    expect(client.key).to eq("some_key")
  end

  it 'uses a key from parameters' do
    client = Notime::Client.new "some_key"
    expect(client.key).to eq("some_key")
  end

  it 'overwrites a key configured from Notime.configure by a parameter key' do
    Notime.configure do |config|
      config.key = "some_key"
      config.group_guid = "some_guid"
    end
    client = Notime::Client.new "overridden_key"
    expect(client.key).to eq("overridden_key")
  end

  describe 'headers & base uri setup' do
    let(:key) { "some_key" }
    let(:client) { Notime::Client.new(key) }

    it 'sets a base url from Notime.url' do
      expect(client.class.base_uri).to eq("https://v1.notimeapi.com/api")
    end

    it 'sets a key header' do
      expect(client.class.headers[Notime::Client::KEY_HEADER]).to eq(key)
    end

    it 'sets json as content type and accept header' do
      expect(client.class.headers['Accept']).to eq("application/json")
      expect(client.class.headers['Content-Type']).to eq("application/json")
    end
  end
end

shared_context 'notime_basic_setup' do
  let(:key) { "some_key" }
  let(:client) { Notime::Client.new(key) }
  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'Ocp-Apim-Subscription-Key' => key } }

  def stub_notime_request method, url, body: nil, response:, status:
    stub_request(method, url).with(body: body, headers: headers).to_return(body: response.to_json, status: status, headers: { 'Content-Type' => "application/json" })
  end
end

shared_examples 'notime_call' do
  include_context 'notime_basic_setup'

  before :each do
    stub_notime_request(http_method, url, body: body, response: response, status: status)
  end

  it 'accepts a block to alter the return value' do
    response = client.send(method, argument) do |response|
      "another result"
    end
    expect(response).to eq("another result")
  end

  it 'calls notime and returns the response' do
    r = client.send(method, argument)
    expect(r.code).to eq(status)
    expect(r.parsed_response).to eq(response)
  end
end

describe Notime::Client, '#shipment' do
  let(:method) { :shipment }
  let(:http_method) { :post }
  let(:url) { "https://v1.notimeapi.com/api/shipment" }
  let(:argument) { {data: 3} }
  let(:body) { argument }
  let(:response) { {"my_response" => "great!"} }
  let(:status) { 200 }

  it_behaves_like('notime_call')
end

describe Notime::Client, '#shipment' do
  let(:method) { :shipment_status }
  let(:http_method) { :get }

  let(:shipment_id) { "some_shipment_id" }
  let(:url) { "https://v1.notimeapi.com/api/shipment/#{shipment_id}/status?languageid=1" }
  let(:body) { nil }
  let(:argument) { shipment_id }
  let(:response) { {"some" => "state"} }
  let(:status) { 200 }

  it_behaves_like('notime_call')
end

describe Notime::Client, '#shipment_cancel' do
  let(:method) { :shipment_cancel }
  let(:http_method) { :put }

  let(:shipment_id) { "some_shipment_id" }
  let(:url) { "https://v1.notimeapi.com/api/shipment/#{shipment_id}/cancel" }
  let(:body) { nil }
  let(:argument) { shipment_id }
  let(:response) { {"some" => "state"} }
  let(:status) { 200 }

  it_behaves_like('notime_call')
end
