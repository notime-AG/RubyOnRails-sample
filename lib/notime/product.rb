module Notime
  class Product
    attr_accessor :reference # optional
    attr_accessor :name, :unit_type, :quantity, :fee, :image_url, :type, :labels
    attr_reader :errors

    NOTIME_HASH_MAPPING = {
      reference: "Reference",
      name: "Name",
      unit_type: "UnitType",
      quantity: "Quantity",
      fee: "Fee",
      image_url: "ImageUrl",
      type: "Type",
      labels: "Labels"
    }.freeze

    def initialize hash = nil
      @errors = []
      init_by_hash(hash) if hash
    end

    def valid?
      @errors = []
      return true if reference.present?
      @errors << ":name is blank!" if name.blank?
      @errors << ":unit_type is blank!" if unit_type.blank?
      @errors << ":labels must be an Array!" if labels && !labels.kind_of?(Array)

      return @errors.empty?
    end

    def to_notime_hash
      hash = {}
      NOTIME_HASH_MAPPING.each do |method,notime_key|
        hash[notime_key] = self.send(method)
      end
      hash
    end

    private
    def init_by_hash hash
      hash.each do |key,value|
        self.send("#{key}=", value)
      end
    end
  end
end
