module Notime
  class MissingConfiguration < StandardError; end
  class MissingKey < StandardError; end
  class MissingGroupGuid < StandardError; end
  class WrongApiVersion < StandardError; end

  BASE_URL = "notimeapi.com/api"
  PROTOCOL = "https"
  API_VERSIONS = ["v1"]

  class << self
    def config
      raise MissingConfiguration if !@config
      @config
    end

    def key
      valid_config?
      config.key
    end

    def version
      valid_config?
      config.version
    end

    def group_guid
      valid_config?
      config.group_guid
    end

    def url
      if @config && valid_config?
        "#{PROTOCOL}://#{version}.#{BASE_URL}"
      else
        "#{PROTOCOL}://#{API_VERSIONS.last}.#{BASE_URL}"
      end
    end

    private
    def valid_config?
      raise MissingKey if config.key.blank?
      raise MissingGroupGuid if config.group_guid.blank?
      raise WrongApiVersion if API_VERSIONS.index(config.version).nil?
    end
  end

  def self.configure
    @config ||= Config.new
    yield(config)
  end

  def self.reset
    @config = nil
  end

  class Config
    attr_accessor :key, :group_guid, :version
    def initialize
      @version = API_VERSIONS.last
    end
  end
end
