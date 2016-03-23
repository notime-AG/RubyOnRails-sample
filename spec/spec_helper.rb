$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry-byebug'
require 'pry-alias'
require 'webmock/rspec'
require 'notime'

RSpec.configure do |config|
  config.order = 'random'

  config.before(:each) do
    Notime.reset
  end
end

# VCR.configure do |c|
#   c.cassette_library_dir = 'spec/cassettes'
#   c.default_cassette_options = { record: :once, match_requests_on: [:method, :uri, :body]}
#   c.hook_into :webmock
#   c.configure_rspec_metadata!
#   c.ignore_localhost = false
#   c.allow_http_connections_when_no_cassette = false
# end

def dummy_configuration
  Notime.configure do |config|
    config.key = "some_key"
    config.group_guid = "some_group_guid"
  end
end

def allow_real_requests
  WebMock.allow_net_connect!
end
