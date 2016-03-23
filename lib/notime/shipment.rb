module Notime
  class Shipment
    class InvalidError < StandardError; end
    class GuidMissing < StandardError; end

    attr_accessor :reference, :guid, :pickup_date, :pickup_time_window_guid, :dropoff_time_window_guid
    attr_accessor :payment_info, :payment_type, :fee, :note, :shipment_type, :asap

    attr_reader :pickup, :dropoff, :products
    attr_reader :errors, :last_result

    NOTIME_HASH_MAPPING = {
      reference: "Reference",
      pickup_date: "PickupDate",
      pickup_time_window_guid: "PickupTimeWindowGuid",
      dropoff_time_window_guid: "DropoffTimeWindowGuid",
      payment_info: "PaymentInfo",
      payment_type: "PaymentType",
      fee: "Fee",
      note: "Note",
      shipment_type: "ShipmentType",
      asap: "ASAP"
    }.freeze

    class << self
      def from_guid guid
        shipment = self.new
        shipment.guid = guid
        shipment
      end
    end

    def initialize hash=nil
      @errors = []
      @products = []
      @pickup = Poi.new
      @dropoff = Poi.new
      init_by_hash(hash) if hash
    end

    def valid?
      @errors = []

      y,m,d = pickup_date.split("-") rescue nil
      if pickup_date.nil? || y.nil? || m.nil? || d.nil? || !Date.valid_date?(y.to_i,m.to_i,d.to_i)
        @errors.push(":pickup_date has a wrong format: '#{pickup_date.to_s}'")
      end

      unless fee.nil?
        fee_number = Float(fee) rescue nil
        if fee_number.nil?
          @errors.push(":fee has a wrong format")
        end
      end

      if !asap.nil? && (asap!=true && asap!=false)
        @errors.push(":asap must be a boolean")
      end

      pickup.valid?
      @errors += pickup.errors
      dropoff.valid?
      @errors += dropoff.errors
      products.each do |product|
        product.valid?
        @errors += product.errors
      end

      @errors.empty?
    end

    # Books a shipment
    # @raise InvalidError is raised when trying to book an invalid shipment
    # @return [Boolean] true if booking was successful, false if an error occured. Errors are stored errors
    def book!
      raise InvalidError unless valid?
      client = get_client
      response = client.shipment self.to_notime_hash
      @last_result = BookResult.new(response)
      self.guid = @last_result.shipment_guid
      @last_result
    end

    def status!
      raise GuidMissing if guid.blank?
      client = get_client
      client.shipment_status(guid)
    end

    def cancel!
      raise GuidMissing if guid.blank?
      client = get_client
      client.shipment_cancel(guid)
    end

    def to_notime_hash
      hash = {"GroupGuid" => Notime.config.group_guid}
      NOTIME_HASH_MAPPING.each do |method,notime_key|
        hash[notime_key] = self.send(method)
      end
      hash["Pickup"] = pickup.to_notime_hash
      hash["Dropoff"] = dropoff.to_notime_hash
      hash["Products"] = products.map(&:to_notime_hash)
      hash
    end

    def add_product &block
      raise "No block given" if block.nil?
      product = Notime::Product.new
      @products << product
      block.call(product)
    end

    private
    def init_by_hash hash
      hash.each do |key,value|
        if key==:pickup
          @pickup = Poi.new(value)
        elsif key==:dropoff
          @dropoff = Poi.new(value)
        elsif key==:products
          value.each do |product_hash|
            product = Product.new(product_hash)
            self.products << product
          end
        else
          self.send("#{key}=", value)
        end
      end
    end

    def get_client
      Notime::Client.new
    end
  end
end
