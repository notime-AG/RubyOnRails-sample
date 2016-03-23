class Notime::Client
  include HTTParty

  KEY_HEADER = "Ocp-Apim-Subscription-Key"

  attr_reader :key

  def initialize key=nil
    begin
      @key = key || (Notime.config ? Notime.config.key : nil)
    rescue Notime::MissingConfiguration
      nil
    end
    raise Notime::Errors::NoKeySet if @key.blank?
    set_base_uri!
    add_key_header!
    add_json_header!
  end

  def shipment body, &block
    perform_api_request(:post, "/shipment", body: body.to_json, &block)
  end

  def shipment_status shipment_id, &block
    perform_api_request(:get, "/shipment/#{shipment_id}/status?languageid=1", &block)
  end

  def shipment_cancel shipment_id, &block
    perform_api_request(:put, "/shipment/#{shipment_id}/cancel", &block)
  end

  private
  def perform_api_request method, *args, &block
    response = self.class.send(method, *args)
    raise_if_error(response)
    response = block.call(response) if block
    response
  end

  def raise_if_error response
    code = response.code
    raise Notime::Errors::AuthenticationFailed.new(response.body) if code==401 || code==403
    raise Notime::Errors::ApiError.new(response.body) if code==500
  end

  def set_base_uri!
    self.class.base_uri(Notime.url)
  end

  def add_key_header!
    self.class.headers.delete(KEY_HEADER)
    self.class.headers KEY_HEADER => key
  end

  def add_json_header!
    self.class.headers 'Accept' => 'application/json'
    self.class.headers 'Content-Type' => 'application/json'
  end
end
