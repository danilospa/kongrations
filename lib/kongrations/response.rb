# frozen_string_literal: true

require 'json'
require 'kongrations/migration_data'

module Kongrations
  class Response
    def initialize(response, request)
      @response = response
      @request = request
    end

    def success?
      @response.is_a?(Net::HTTPSuccess)
    end

    def error?
      !success?
    end

    def body
      JSON.parse(@response.body, symbolize_names: true) unless @response.body.nil?
    end

    def data_to_save
      nil
    end

    def save_data(migration_name)
      MigrationData.save(migration_name, data_to_save)
    end
  end
end
