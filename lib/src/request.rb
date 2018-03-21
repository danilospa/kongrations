# frozen_string_literal: true

require_relative './migration_data'
require 'net/http'
require 'json'

Dir["#{__dir__}/responses/*.rb"].each { |file| require file }

class Request
  attr_accessor :payload

  METHODS_MAPPER = {
    post: Net::HTTP::Post,
    patch: Net::HTTP::Patch,
    delete: Net::HTTP::Delete
  }.freeze

  def execute
    http = Net::HTTP.new('', 80)
    request = METHODS_MAPPER[method].new(path, { 'Content-Type' => 'application/json', 'apikey' => '' })
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
