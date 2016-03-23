require 'spec_helper'

describe Notime do
  it 'should store key and client_secret' do
    Notime.configure do |config|
      config.key = 'some_key'
      config.group_guid = 'my_group_guid'
    end

    expect(Notime.key).to eq('some_key')
    expect(Notime.group_guid).to eq('my_group_guid')
  end

  context "valid configuration" do
    before :each do
      Notime.configure do |config|
        config.key = 'some_key'
        config.group_guid = 'my_group_guid'
      end
    end

    it "should reset the configuration" do
      Notime.reset
      expect { Notime.config }.to raise_error Notime::MissingConfiguration
    end

    it 'returns the api url' do
      expect(Notime.url).to eq("https://v1.notimeapi.com/api")
    end

    it 'returns the key' do
      expect(Notime.key).to eq("some_key")
    end

    it 'returns the group_guid' do
      expect(Notime.group_guid).to eq("my_group_guid")
    end
  end

  context 'basic values without configuration' do
    it 'returns a basic URL without calling .configure' do
      expect(Notime.url).to eq("https://v1.notimeapi.com/api")
    end
  end

  describe "errors" do
    it "should raise configuration errors" do
      expect { Notime.key }.to raise_error Notime::MissingConfiguration

      Notime.configure do |config|
      end
      expect { Notime.key }.to raise_error Notime::MissingKey

      Notime.configure do |config|
        config.key = ""
      end
      expect { Notime.key }.to raise_error Notime::MissingKey

      Notime.configure do |config|
        config.key = "some_key"
      end
      expect { Notime.group_guid }.to raise_error Notime::MissingGroupGuid

      Notime.configure do |config|
        config.key = "some_key"
        config.group_guid = ""
      end
      expect { Notime.group_guid }.to raise_error Notime::MissingGroupGuid

      Notime.configure do |config|
        config.key = "some_key"
        config.group_guid = "group_guid"
        config.version = ""
      end
      expect { Notime.version }.to raise_error Notime::WrongApiVersion
    end

    it "should raise read only errors" do
      Notime.configure do |config|
        config.key = "some_key"
        config.group_guid = "group_guid"
      end

      expect { Notime.key = "foobar" }.to raise_error NoMethodError
      expect { Notime.group_guid = "foobar" }.to raise_error NoMethodError
      expect { Notime.version = "foobar" }.to raise_error NoMethodError
      expect { Notime.url = "foobar" }.to raise_error NoMethodError
    end
  end
end
