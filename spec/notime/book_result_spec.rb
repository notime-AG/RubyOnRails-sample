require 'spec_helper'

describe Notime::BookResult, '#initialize' do
  it 'inits with a notime hash' do
    error_string = "{\"shipment.PickupTimeWindowGuid\":[\"Error converting value \\\"aaaC8E32DAA-75A5-414D-B1D1-BAB6D4D8DEE2\\\" to type 'System.Nullable`1[System.Guid]'. Path 'PickupTimeWindowGuid', line 1, position 142.\"]}"
    hash = {
      "ResultCode"=>0,
      "ResultText"=>"Success",
      "ShipmentGuid"=>"guid",
      "PickupReference"=>"pickup_ref1",
      "DropoffReference"=>"dropoff_ref1",
      "ErrorString"=>error_string
    }
    result = described_class.new hash
    expect(result.result_code).to eq(0)
    expect(result.result_text).to eq("Success")
    expect(result.shipment_guid).to eq("guid")
    expect(result.pickup_reference).to eq("pickup_ref1")
    expect(result.dropoff_reference).to eq("dropoff_ref1")
    expect(result.error_string).to eq(error_string)
    expect(result.success?).to be(true)
    expect(result.errors).to eq({"shipment.PickupTimeWindowGuid"=>["Error converting value \"aaaC8E32DAA-75A5-414D-B1D1-BAB6D4D8DEE2\" to type 'System.Nullable`1[System.Guid]'. Path 'PickupTimeWindowGuid', line 1, position 142."]})
  end
end
