# frozen_string_literal: true

require 'yaml'
require 'erb'

module Kongrations
  module CurrentEnvironment
    FILE_NAME = 'kongrations.yml'

    def self.load!(name)
      yaml = File.read(FILE_NAME)

      template = ERB.new(yaml)
      yaml = template.result(binding)

      config = YAML.safe_load(yaml)
      environment = config['environments'].detect { |e| e['name'] == name }

      @migrations_folder = config.fetch('path', './migrations')
      @name = name
      @kong_admin_url = environment['kong-admin-url']
      @kong_admin_api_key = environment['kong-admin-api-key']
    end

    def self.migrations_folder
      @migrations_folder
    end

    def self.name
      @name
    end

    def self.kong_admin_url
      @kong_admin_url
    end

    def self.kong_admin_api_key
      @kong_admin_api_key
    end
  end
end
