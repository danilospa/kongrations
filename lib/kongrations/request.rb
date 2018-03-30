# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative './migration_data'
require_relative './current_environment'

Dir["#{__dir__}/responses/*.rb"].each { |file| require file }

module Kongrations
  class Request
    attr_accessor :payload

    METHODS_MAPPER = {
      post: Net::HTTP::Post,
      patch: Net::HTTP::Patch,
      delete: Net::HTTP::Delete
    }.freeze

    def execute
      http = Net::HTTP.new(CurrentEnvironment.kong_admin_url, 80)
      headers = {
        'Content-Type' => 'application/json',
        'apikey' => CurrentEnvironment.kong_admin_api_key
      }

      request = METHODS_MAPPER[method].new(path, headers)
      request.body = payload.to_json unless payload.nil?
      response = http.request(request)
      initialize_response_class(response)
    end

    def initialize_response_class(response)
      class_name = self.class.to_s.gsub('Request', 'Response')
      klass = Object.const_defined?(class_name) ? Object.const_get(class_name) : Response
      klass.new(response, self)
    end

    def migration_data
      MigrationData.data
    end
  end
end
