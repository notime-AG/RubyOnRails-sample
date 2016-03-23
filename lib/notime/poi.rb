module Notime
  class Poi
    attr_accessor :reference # optional
    attr_accessor :street_address, :city, :post_code, :country_code # mandatory when no reference is given
    attr_accessor :name, :phone, :contact_name, :note, :labels # optional

    attr_reader :errors

    NOTIME_HASH_MAPPING = {
      reference: "Reference",
      street_address: "StreetAddress",
      city: "City",
      post_code: "PostCode",
      country_code: "CountryCode",
      name: "Name",
      phone: "Phone",
      contact_name: "ContactName",
      note: "Note",
      labels: "Labels"
    }.freeze

    def initialize hash=nil
      @errors = []
      if hash
        init_by_hash(hash)
      end
    end

    def valid?
      @errors = []
      return true if reference.present? # when a reference is given no other field is required
      errors.push(":street_address is blank!") if street_address.blank?
      errors.push(":city is blank!") if city.blank?
      errors.push(":post_code is blank!") if post_code.blank?
      errors.push(":country_code is blank!") if country_code.blank?
      errors.push(":labels must be an Array!") if labels && !labels.kind_of?(Array)
      errors.empty?
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
