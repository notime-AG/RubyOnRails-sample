class Notime::BookResult
  attr_reader :result_code, :result_text, :shipment_guid, :pickup_reference, :dropoff_reference, :error_string

  def initialize hash
    @result_code = hash["ResultCode"]
    @result_text = hash["ResultText"]
    @shipment_guid = hash["ShipmentGuid"]
    @pickup_reference = hash["PickupReference"]
    @dropoff_reference = hash["DropoffReference"]
    @error_string = hash["ErrorString"]
  end

  def success?
    result_code == 0
  end

  def errors
    return if @error_string.blank?
    JSON.parse(@error_string)
  end
end
